import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_ro_dashboard/data/socket_server/base_xt_response.dart';
import 'package:app_ro_dashboard/log.dart';

class XSServer {
  static ServerSocket? _server;
  static final StreamController<BaseDTO> _streamController =
      StreamController();
  static final List<Socket> _clients = [];

  Future<ServerSocket>? close() {
    return _server?.close();
  }

  static void on(String event, Function(String body) callback) {
    _streamController.stream.listen((current) {
      if (event == current.event) {
        callback.call(current.body);
      }
    });
  }

  static void sendAll(String event, String message) {
    for (var element in _clients) {
      element.write(
          jsonEncode(BaseDTO(event: event, body: message).toMap()));
    }
  }

  static Future<void> start() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 5555)
        .then((value) async {
      printSafe('Server started on port ${value.port}   ${value.address.host}');
      value.listen(handleConnection);
      return null;
    });
  }

  static void handleConnection(Socket client) {
    printSafe('Connection from'
        '${client.remoteAddress.address}:${client.remotePort}');
    _clients.add(client);
    // listen for events from the client
    client.listen(
      // handle data from the client
      (Uint8List data) async {
        final message = String.fromCharCodes(data);
        final decoded = BaseDTO.fromMap(jsonDecode(message));
        printSafe("(CLIENT)[${client.remoteAddress.address}] : $message");
        _streamController.add(decoded);
      },

      // handle errors
      onError: (error) {
        printSafe(error);
        _clients.removeWhere(
            (element) => element.remoteAddress == client.remoteAddress);
        client.close();
      },

      // handle the client closing the connection
      onDone: () {
        _clients.removeWhere(
            (element) => element.remoteAddress == client.remoteAddress);
        printSafe('Client left');
        client.close();
      },
    );
  }
}
