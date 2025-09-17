import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class TableListPage extends StatelessWidget {
  const TableListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tavoli Ristorante'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.5,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          final tableNumber = index + 1;
          return TableCard(
            tableNumber: tableNumber,
            onTap: () {
              _showOrderDialog(context, tableNumber);
            },
          );
        },
      ),
    );
  }

  void _showOrderDialog(BuildContext context, int tableNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TableOrderDialog(
          tableNumber: tableNumber,
        );
      },
    );
  }
}

class TableCard extends StatelessWidget {
  final int tableNumber;
  final VoidCallback onTap;

  const TableCard({
    super.key,
    required this.tableNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            'Tavolo $tableNumber',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class TableOrderDialog extends StatelessWidget {
  final int tableNumber;
  final DatabaseService _db = DatabaseService();

  TableOrderDialog({
    super.key,
    required this.tableNumber,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _db.streamOrder(tableNumber),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Si è verificato un errore');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final Map<String, dynamic> orderData = snapshot.data?.data() ?? {};
        final Map<String, int> currentOrder =
            (orderData['items'] as Map<String, dynamic>?)?.map(
                  (key, value) => MapEntry(key, value as int),
                ) ??
                {};

        return AlertDialog(
          title: Text('Ordine Tavolo $tableNumber'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aggiungi prodotti:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildMenuItem(context, currentOrder, 'Pizza Margherita'),
                _buildMenuItem(context, currentOrder, 'Pizza Diavola'),
                _buildMenuItem(context, currentOrder, 'Coca Cola'),
                _buildMenuItem(context, currentOrder, 'Acqua'),
                const SizedBox(height: 20),
                const Text(
                  'Riepilogo Ordine:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...currentOrder.entries.map((entry) {
                  return Row(
                    children: [
                      Text('${entry.value} x ${entry.key}'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          _updateOrder(
                            currentOrder,
                            entry.key,
                            isAdd: false,
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
                const Divider(),
                Text(
                  'Totale: €${_calculateTotal(currentOrder).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _clearOrder(),
              child: const Text('Azzera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  void _updateOrder(
    Map<String, int> currentOrder,
    String item, {
    required bool isAdd,
  }) {
    final Map<String, int> newOrder = Map.from(currentOrder);
    if (isAdd) {
      newOrder.update(item, (value) => value + 1, ifAbsent: () => 1);
    } else {
      if (newOrder.containsKey(item)) {
        newOrder.update(item, (value) => value - 1);
        if (newOrder[item]! <= 0) {
          newOrder.remove(item);
        }
      }
    }
    _db.updateOrder(tableNumber.toString(), {'items': newOrder});
  }

  void _clearOrder() {
    _db.updateOrder(tableNumber.toString(), {'items': {}});
  }

  double _calculateTotal(Map<String, int> order) {
    double total = 0.0;
    const menuPrices = {
      'Pizza Margherita': 7.50,
      'Pizza Diavola': 9.00,
      'Coca Cola': 3.00,
      'Acqua': 2.00,
    };
    order.forEach((item, quantity) {
      if (menuPrices.containsKey(item)) {
        total += menuPrices[item]! * quantity;
      }
    });
    return total;
  }

  Widget _buildMenuItem(
    BuildContext context,
    Map<String, int> currentOrder,
    String item,
  ) {
    return Row(
      children: [
        Expanded(child: Text(item)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            _updateOrder(currentOrder, item, isAdd: true);
          },
        ),
      ],
    );
  }
}