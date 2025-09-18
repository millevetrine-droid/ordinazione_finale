import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordini in Tempo Reale'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dbService.streamAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Si è verificato un errore'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nessun ordine attivo.'));
          }

          final orders = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'items': (data['items'] as Map<String, dynamic>).map(
                    (key, value) => MapEntry(key, value as int),
              ),
              'ready': data['ready'] ?? false,
            };
          }).toList();

          final readyOrders = orders.where((order) => order['ready'] == true).toList();
          final pendingOrders = orders.where((order) => order['ready'] == false).toList();

          return ListView(
            children: [
              if (pendingOrders.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'In Preparazione',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ...pendingOrders.map((order) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('Tavolo ${order['id']}'),
                      subtitle: Text(
                        (order['items'] as Map<String, int>).entries.map((e) => '${e.value} x ${e.key}').join('\n'),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          dbService.cancelOrder(order['id'] as String);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
              if (readyOrders.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Pronto per il Ritiro',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ...readyOrders.map((order) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.green[100],
                    child: ListTile(
                      title: Text('Tavolo ${order['id']}'),
                      subtitle: Text(
                        (order['items'] as Map<String, int>).entries.map((e) => '${e.value} x ${e.key}').join('\n'),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () {
                          // TODO: Implement logic to archive the order
                          dbService.completeOrder(order['id'] as String);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await dbService.createOrder(
            'tavolo_1',
            {
              'pizza_margherita': 2,
              'coca_cola': 3,
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ordine di prova creato per Tavolo 1')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}