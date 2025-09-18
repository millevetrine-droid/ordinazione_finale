// lib/database_service.dart

import 'dart:async';
import 'package:ordinazione_finale/models/order.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Liste fittizie di ordini
  static final List<Order> _allOrders = [
    Order(id: 1, customerName: 'Mario Rossi', status: 'In preparazione'),
    Order(id: 2, customerName: 'Giulia Verdi', status: 'In consegna'),
  ];

  static final List<Order> _archivedOrders = [
    Order(id: 3, customerName: 'Luca Bianchi', status: 'Completato'),
  ];
  
  // Metodo per ottenere tutti gli ordini (usato per l'OrderListPage)
  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.from(_allOrders);
  }

  // Metodo per ottenere gli ordini archiviati
  Future<List<Order>> getArchivedOrders() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.from(_archivedOrders);
  }

  // Metodo per segnare un ordine come pronto (per la KitchenPage)
  void markOrderAsReady(int orderId) {
    try {
      final orderIndex = _allOrders.indexWhere((o) => o.id == orderId);
      if (orderIndex != -1) {
        final order = _allOrders.removeAt(orderIndex);
        _archivedOrders.add(order);
      }
    } catch (e) {
      print('Ordine non trovato: $e');
    }
  }

  // Metodo per ripristinare un ordine dall'archivio (per l'ArchivePage)
  void restoreOrder(int orderId) {
    try {
      final orderIndex = _archivedOrders.indexWhere((o) => o.id == orderId);
      if (orderIndex != -1) {
        final order = _archivedOrders.removeAt(orderIndex);
        // Aggiorna lo stato dell'ordine a 'In preparazione'
        order.status = 'In preparazione';
        _allOrders.add(order);
      }
    } catch (e) {
      print('Ordine archiviato non trovato: $e');
    }
  }
}