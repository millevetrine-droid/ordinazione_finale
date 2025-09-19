// lib/kitchen_page.dart

import 'package:flutter/material.dart';
import 'package:ordinazione_finale/database_service.dart';
import 'package:ordinazione_finale/models/order.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  _KitchenPageState createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = DatabaseService().getOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = DatabaseService().getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cucina'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];
          final kitchenOrders = orders.where((order) => order.status == 'In preparazione').toList();

          if (kitchenOrders.isEmpty) {
            return const Center(child: Text('Nessun ordine in cucina.'));
          }

          return ListView.builder(
            itemCount: kitchenOrders.length,
            itemBuilder: (context, index) {
              final order = kitchenOrders[index];
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordine #${order.id} - Tavolo ${order.tableNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ...order.items.where((item) => item.itemStatus == 'In preparazione').map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.itemName,
                                style: const TextStyle(fontSize: 16),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  DatabaseService().markItemAsReady(order.id, item.itemName);
                                  _refreshOrders();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${item.itemName} segnato come pronto!')),
                                  );
                                },
                                child: const Text('Pronto'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}