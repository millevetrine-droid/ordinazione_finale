import 'package:flutter/material.dart';
import 'database_service.dart';

// Elenco dei prodotti disponibili
class MenuItem {
  final String name;
  final double price;

  MenuItem(this.name, this.price);
}

final List<MenuItem> menu = [
  MenuItem('Pizza Margherita', 7.50),
  MenuItem('Pizza Marinara', 6.00),
  MenuItem('Pizza Diavola', 8.50),
  MenuItem('Acqua', 2.00),
  MenuItem('Coca-Cola', 3.00),
  MenuItem('Birra', 4.00),
];

class TableListPage extends StatefulWidget {
  const TableListPage({super.key});

  @override
  State<TableListPage> createState() => _TableListPageState();
}

class _TableListPageState extends State<TableListPage> {
  final DatabaseService dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona un tavolo'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          final tableNumber = index + 1;
          return _buildTableCard(tableNumber);
        },
      ),
    );
  }

  Widget _buildTableCard(int tableNumber) {
    return Card(
      color: Colors.blue[100],
      child: InkWell(
        onTap: () => _showOrderDialog(tableNumber),
        child: Center(
          child: Text(
            'Tavolo $tableNumber',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Future<void> _showOrderDialog(int tableNumber) async {
    final docSnapshot = await dbService.streamOrder(tableNumber).first;
    final currentOrder =
        (docSnapshot.data()?['items'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, value as int),
            ) ??
            {};

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Ordine Tavolo $tableNumber'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ...menu.map((item) {
                      return ListTile(
                        title: Text(item.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (currentOrder.containsKey(item.name) &&
                                (currentOrder[item.name] ?? 0) > 0)
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    final itemCount =
                                        (currentOrder[item.name] ?? 0) - 1;
                                    if (itemCount > 0) {
                                      currentOrder[item.name] = itemCount;
                                    } else {
                                      currentOrder.remove(item.name);
                                    }
                                  });
                                },
                              ),
                            Text('${currentOrder[item.name] ?? 0}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  currentOrder[item.name] =
                                      (currentOrder[item.name] ?? 0) + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Annulla'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Salva'),
                  onPressed: () {
                    dbService.updateOrder(
                        tableNumber.toString(), {'items': currentOrder});
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}