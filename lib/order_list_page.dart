// lib/order_list_page.dart

import 'package:flutter/material.dart';
import 'package:ordinazione_finale/database_service.dart';
import 'package:ordinazione_finale/models/order.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late Future<List<Order>> _ordersFuture;
  bool _showInProgressOnly = false;

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
        title: const Text('Ordini'),
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
          final displayedOrders = _showInProgressOnly
              ? orders.where((order) => order.status == 'In preparazione').toList()
              : orders.where((order) => order.status == 'In consegna').toList();

          if (displayedOrders.isEmpty) {
            return const Center(child: Text('Nessun ordine disponibile.'));
          }

          return ListView.builder(
            itemCount: displayedOrders.length,
            itemBuilder: (context, index) {
              final order = displayedOrders[index];
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    'Ordine #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Cliente: ${order.customerName}\nStato: ${order.status}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showInProgressOnly = !_showInProgressOnly;
          });
        },
        label: Text(_showInProgressOnly ? 'Mostra ordini in consegna' : 'Mostra ordini in preparazione'),
        icon: const Icon(Icons.receipt_long),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}