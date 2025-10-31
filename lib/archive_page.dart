// lib/archive_page.dart

import 'package:flutter/material.dart';
import 'package:ordinazione/database_service.dart';
import 'package:ordinazione/models/order.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Archivio Ordini'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Archivio Sala'),
              Tab(text: 'Archivio Cucina'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildArchiveList(DatabaseService().getWaiterArchive()),
            _buildArchiveList(DatabaseService().getKitchenArchive()),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveList(Future<List<Order>> ordersFuture) {
    return FutureBuilder<List<Order>>(
      future: ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text('Nessun ordine in questo archivio.'));
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
                    Text('Stato: ${order.status}'),
                    const Text('Piatti:'),
                    ...order.items.map((item) => Text('- ${item.itemName}')),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    DatabaseService().restoreOrder(order.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ordine #${order.id} ripristinato!')),
                    );
                    setState(() {});
                  },
                  child: const Text('Ripristina'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}