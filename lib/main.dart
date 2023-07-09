import 'dart:convert';

import 'package:app_ro_dashboard/log.dart';
import 'package:app_ro_dashboard/domain/models/order_item_request.dart';
import 'package:flutter/material.dart';

import 'data/socket_server/XTServer.dart';
import 'data/socket_server/stream_socket.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  StreamSocket<OrderItemRequest> streamSocket =
      StreamSocket<OrderItemRequest>();

  void _incrementCounter() {
    XSServer.start();
    XSServer.on('new_order', (body) {
      final newOrder = OrderItemRequest.fromMap(jsonDecode(body));
      printSafe(newOrder.toMap());
      streamSocket.add(newOrder);
    });

    streamSocket.get.listen((event) {
      print(event.toMap());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        children: [
          FloatingActionButton(
            onPressed: () {
              XSServer.sendAll("changes_prods", _controller.text);
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
