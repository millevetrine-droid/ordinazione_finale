// lib/waiter_order_page.dart

import 'package:flutter/material.dart';
import 'package:ordinazione_finale/database_service.dart';
import 'package:ordinazione_finale/models/order.dart';

class WaiterOrderPage extends StatefulWidget {
  const WaiterOrderPage({super.key});

  @override
  _WaiterOrderPageState createState() => _WaiterOrderPageState();
}

class _WaiterOrderPageState extends State<WaiterOrderPage> {
  bool _showInPreparation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showInPreparation ? 'Ordini in preparazione' : 'Ordini da consegnare'),
        actions: [
          IconButton(
            icon: Icon(_showInPreparation ? Icons.delivery_dining : Icons.restaurant_menu),
            onPressed: () {
              setState(() {
                _showInPreparation = !_showInPreparation;
              });
            },
            tooltip: _showInPreparation ? 'Mostra da consegnare' : 'Mostra in preparazione',
          ),
        ],
      ),
      body: StreamBuilder<List<Order>>(
        stream: DatabaseService().getOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final allOrders = snapshot.data ?? [];
          final itemsToShow = allOrders
              .expand((order) => order.items.map((item) => ReadyItemForDelivery(
                    orderId: order.id,
                    tableNumber: order.tableNumber,
                    item: item,
                  )))
              .where((item) => _showInPreparation
                  ? item.item.itemStatus == ItemStatus.inPreparation
                  : item.item.itemStatus == ItemStatus.ready)
              .toList();

          if (itemsToShow.isEmpty) {
            return const Center(child: Text('Nessun piatto in questa sezione.'));
          }

          return ListView.builder(
            itemCount: itemsToShow.length,
            itemBuilder: (context, index) {
              final item = itemsToShow[index];
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(item.item.itemName),
                  subtitle: Text('Tavolo ${item.tableNumber} - Stato: ${item.item.itemStatus.name}'),
                  trailing: _showInPreparation
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            // TODO: implementare la logica per spostare nell'archivio della sala
                          },
                          tooltip: 'Consegna',
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}