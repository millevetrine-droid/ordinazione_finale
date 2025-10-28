// lib/menu_page.dart

import 'package:flutter/material.dart';
import 'package:ordinazione/menu_service.dart';
import 'package:ordinazione/models/menu_item.dart';
import 'package:ordinazione/models/item.dart';
import 'package:ordinazione/customer_registration_page.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback? onStaffLogin;

  const MenuPage({super.key, this.onStaffLogin});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<MenuItem>> _menuItemsFuture;
  final List<MenuItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = MenuService().getMenuItems();
  }

  void _addItemToOrder(MenuItem item) {
    setState(() {
      _selectedItems.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} aggiunto all\'ordine!'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _placeOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerRegistrationPage(
          selectedItems: _selectedItems
              .map((m) => Item(itemName: m.name, price: m.price, itemStatus: ItemStatus.inPreparation))
              .toList(),
        ),
      ),
    ).then((_) {
      // Pulisci il carrello dopo che il cliente ha completato l'azione
      setState(() {
        _selectedItems.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: widget.onStaffLogin,
            tooltip: 'Area Riservata',
          ),
        ],
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final menuItems = snapshot.data ?? [];
          if (menuItems.isEmpty) {
            return const Center(child: Text('Nessun piatto disponibile nel menu.'));
          }

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('€${item.price.toStringAsFixed(2)}'),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addItemToOrder(item),
                        child: const Text('Aggiungi'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _selectedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _placeOrder,
              label: Text('Conferma Ordine (${_selectedItems.length})'),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}