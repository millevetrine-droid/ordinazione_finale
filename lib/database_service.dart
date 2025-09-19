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

  static final List<Order> _kitchenArchive = [];
  static final List<Order> _waiterArchive = [
    Order(id: 3, customerName: 'Luca Bianchi', status: 'Completato'),
  ];
  
  // Metodo per ottenere tutti gli ordini
  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.from(_allOrders);
  }

  // Metodo per ottenere gli ordini archiviati della cucina
  Future<List<Order>> getKitchenArchive() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.from(_kitchenArchive);
  }

  // Metodo per ottenere gli ordini archiviati della sala
  Future<List<Order>> getWaiterArchive() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.from(_waiterArchive);
  }

  // Metodo per segnare un ordine come pronto (per la KitchenPage)
  void markOrderAsReady(int orderId) {
    try {
      final orderIndex = _allOrders.indexWhere((o) => o.id == orderId);
      if (orderIndex != -1) {
        final order = _allOrders.removeAt(orderIndex);
        order.status = 'In consegna';
        _kitchenArchive.add(order);
      }
    } catch (e) {
      print('Ordine non trovato: $e');
    }
  }

  // Metodo per ripristinare un ordine dall'archivio (per l'ArchivePage)
  void restoreOrder(int orderId) {
    Order? orderToRestore;
    // Cerca l'ordine nell'archivio della cucina
    final kitchenIndex = _kitchenArchive.indexWhere((o) => o.id == orderId);
    if (kitchenIndex != -1) {
      orderToRestore = _kitchenArchive.removeAt(kitchenIndex);
    } else {
      // Se non è lì, cercalo nell'archivio della sala
      final waiterIndex = _waiterArchive.indexWhere((o) => o.id == orderId);
      if (waiterIndex != -1) {
        orderToRestore = _waiterArchive.removeAt(waiterIndex);
      }
    }

    if (orderToRestore != null) {
      // Aggiorna lo stato dell'ordine a 'In preparazione'
      orderToRestore.status = 'In preparazione';
      _allOrders.add(orderToRestore);
    } else {
      print('Ordine archiviato non trovato: $orderId');
    }
  }
  
  // Metodo per completare un ordine (per la OrderListPage)
  void completeOrder(int orderId) {
    try {
      final orderIndex = _allOrders.indexWhere((o) => o.id == orderId);
      if (orderIndex != -1) {
        final order = _allOrders.removeAt(orderIndex);
        order.status = 'Completato';
        _waiterArchive.add(order);
      }
    } catch (e) {
      print('Ordine non trovato: $e');
    }
  }
}