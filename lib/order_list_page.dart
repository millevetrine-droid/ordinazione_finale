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

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final tableNumber = doc.id;
              final items = (data['items'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, value as int),
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Tavolo $tableNumber'),
                  subtitle: Text(
                    items.entries
                        .map((e) => '${e.value} x ${e.key}')
                        .join('\n'),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          dbService.cancelOrder(tableNumber);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Simuliamo un ordine di prova per testare il sistema
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