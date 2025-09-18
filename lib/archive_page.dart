// lib/archive_page.dart

import 'package:flutter/material.dart';
import 'package:ordinazione_finale/database_service.dart';
import 'package:ordinazione_finale/models/order.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  late Future<List<Order>> _archivedOrdersFuture;

  @override
  void initState() {
    super.initState();
    _archivedOrdersFuture = DatabaseService().getArchivedOrders();
  }

  void _refreshArchivedOrders() {
    setState(() {
      _archivedOrdersFuture = DatabaseService().getArchivedOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivio Ordini'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _archivedOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('Nessun ordine archiviato.'));
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
                    'Ordine #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Cliente: ${order.customerName}\nStato: ${order.status}'),
                  trailing: order.status == 'Completato'
                      ? ElevatedButton(
                          onPressed: () {
                            DatabaseService().restoreOrder(order.id);
                            _refreshArchivedOrders();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ordine #${order.id} ripristinato!')),
                            );
                          },
                          child: const Text('Ripristina'),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}