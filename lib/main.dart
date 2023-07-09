import 'dart:convert';

import 'package:app_ro_dashboard/domain/models/order_item_request.dart';
import 'package:flutter/material.dart';

import 'data/socket_server/XTServer.dart';
import 'domain/models/transfer.dart';

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

  // StreamSocket<OrderItemRequest> streamSocket = StreamSocket<OrderItemRequest>();
  List<OrderTable> _tables = [];

  void _incrementCounter() {
    XSServer.start();
    XSServer.on('new_order', (body) {
      final newOrder = TransferDTO.fromMap(jsonDecode(body));
      _tables = newOrder.data;
      setState(() {});
      // streamSocket.add(newOrder);
    });

    // streamSocket.get.listen((event) {
    //   print(event.toMap());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            Flexible(
              child: FloatingActionButton(
                onPressed: () {
                  XSServer.sendAll("changes_prods", _controller.text);
                },
                tooltip: 'Increment',
                child: const Icon(Icons.send),
              ),
            ),
            Flexible(
              child: FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemBuilder: (e, i) {
          final orders = _tables[i];
          return GestureDetector(
            onTap: () {
              //
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.greenAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...orders.orders.map(
                    (e) {
                      return Row(
                        children: [
                          Text('${e.name}    x${e.count}'),
                          const Padding(
                            padding: EdgeInsets.all(24),
                          ),
                          Text('${e.count * e.price}'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: _tables.length,
      ),
    );
  }
}

extension Iterables<E> on List<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}
