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
  late Future<List<ReadyItemForDelivery>> _readyItemsFuture;
  bool _showInProgressOnly = true;

  @override
  void initState() {
    super.initState();
    _ordersFuture = DatabaseService().getOrders();
    _readyItemsFuture = DatabaseService().getReadyForDeliveryItems();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = DatabaseService().getOrders();
      _readyItemsFuture = DatabaseService().getReadyForDeliveryItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = _showInProgressOnly ? 'Ordini in preparazione' : 'Ordini da consegnare';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: _showInProgressOnly ? _buildInProgressOrders() : _buildReadyForDeliveryItems(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showInProgressOnly = !_showInProgressOnly;
          });
        },
        label: Text(_showInProgressOnly ? 'Mostra ordini da consegnare' : 'Mostra ordini in preparazione'),
        icon: const Icon(Icons.receipt_long),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInProgressOrders() {
    return FutureBuilder<List<Order>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text('Nessun ordine in preparazione.'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(
                  'Ordine #${order.id} - Tavolo ${order.tableNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Piatti:'),
                    ...order.items.where((item) => item.itemStatus == 'In preparazione').map((item) => Text('- ${item.itemName}')).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReadyForDeliveryItems() {
    return FutureBuilder<List<ReadyItemForDelivery>>(
      future: _readyItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }

        final readyItems = snapshot.data ?? [];
        if (readyItems.isEmpty) {
          return const Center(child: Text('Nessun piatto da consegnare.'));
        }

        return ListView.builder(
          itemCount: readyItems.length,
          itemBuilder: (context, index) {
            final readyItem = readyItems[index];
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(
                  'Tavolo ${readyItem.tableNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(readyItem.item.itemName),
                trailing: ElevatedButton(
                  onPressed: () {
                    DatabaseService().completeItem(readyItem.tableNumber, readyItem.item.itemName);
                    _refreshOrders();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${readyItem.item.itemName} del tavolo ${readyItem.tableNumber} consegnato!')),
                    );
                  },
                  child: const Text('Consegna'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}