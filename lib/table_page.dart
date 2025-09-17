import 'package:flutter/material.dart';

class TablePage extends StatefulWidget {
  final int tableNumber;

  const TablePage({super.key, required this.tableNumber});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  // Mappa per tenere traccia degli articoli ordinati e delle loro quantità
  final Map<String, int> _orderedItems = {};

  // Lista di mappe per gli articoli del menu con nome e prezzo
  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Pizza Margherita', 'price': 8.50},
    {'name': 'Spaghetti alla Carbonara', 'price': 10.00},
    {'name': 'Risotto ai funghi', 'price': 9.50},
    {'name': 'Acqua naturale', 'price': 2.00},
    {'name': 'Coca-Cola', 'price': 3.50},
    {'name': 'Birra', 'price': 5.00},
  ];

  // Funzione per calcolare il sub-totale dell'ordine
  double _calculateSubtotal() {
    double total = 0.0;
    _orderedItems.forEach((item, quantity) {
      final itemPrice = menuItems.firstWhere((element) => element['name'] == item)['price'] as double;
      total += itemPrice * quantity;
    });
    return total;
  }

  // Funzione per mostrare un riepilogo dell'ordine
  void _showOrderSummary() {
    final subtotal = _calculateSubtotal();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Riepilogo Ordine'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ..._orderedItems.keys.map((item) {
                  final quantity = _orderedItems[item];
                  return Text('$item: $quantity');
                }).toList(),
                const Divider(),
                Text('Totale: €${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordinazione Tavolo ${widget.tableNumber}'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final itemName = item['name'] as String;
          final itemPrice = item['price'] as double;
          final quantity = _orderedItems[itemName] ?? 0;
          return ListTile(
            title: Text(itemName),
            subtitle: Text('€${itemPrice.toStringAsFixed(2)}'),
            trailing: quantity > 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            if (quantity > 0) {
                              _orderedItems[itemName] = quantity - 1;
                            }
                          });
                        },
                      ),
                      Text('$quantity',
                          style: Theme.of(context).textTheme.headlineSmall),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          setState(() {
                            _orderedItems[itemName] = quantity + 1;
                          });
                        },
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      setState(() {
                        _orderedItems[itemName] = 1;
                      });
                    },
                  ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showOrderSummary,
            heroTag: "btn1",
            child: const Icon(Icons.receipt),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _orderedItems.clear();
              });
            },
            heroTag: "btn2",
            child: const Icon(Icons.delete_forever),
          ),
        ],
      ),
    );
  }
}