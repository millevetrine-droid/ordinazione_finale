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

  // Lista statica di articoli del menu
  final List<String> menuItems = [
    'Pizza Margherita',
    'Spaghetti alla Carbonara',
    'Risotto ai funghi',
    'Acqua naturale',
    'Coca-Cola',
    'Birra'
  ];

  // Funzione per mostrare un riepilogo dell'ordine
  void _showOrderSummary() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Riepilogo Ordine'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _orderedItems.keys.map((item) {
                final quantity = _orderedItems[item];
                return Text('$item: $quantity');
              }).toList(),
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
          final quantity = _orderedItems[item] ?? 0;
          return ListTile(
            title: Text(item),
            trailing: quantity > 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            if (quantity > 0) {
                              _orderedItems[item] = quantity - 1;
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
                            _orderedItems[item] = quantity + 1;
                          });
                        },
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      setState(() {
                        _orderedItems[item] = 1;
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