// lib/database_service.dart

import 'dart:async';
import 'package:ordinazione/models/order.dart';
import 'package:ordinazione/models/item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Liste fittizie di ordini
  static final List<Order> _allOrders = [
    Order(
      id: 1,
      tableNumber: 5,
      items: [
        Item(itemName: 'Pizza Margherita', price: 7.5, itemStatus: ItemStatus.inPreparation),
        Item(itemName: 'Coca-Cola', price: 2.5, itemStatus: ItemStatus.inPreparation),
      ],
      status: ItemStatus.inPreparation,
    ),
    Order(
      id: 2,
      tableNumber: 5,
      items: [
        Item(itemName: 'Tiramisù', price: 4.0, itemStatus: ItemStatus.inPreparation),
      ],
      status: ItemStatus.inPreparation,
    ),
    Order(
      id: 3,
      tableNumber: 8,
      items: [
        Item(itemName: 'Spaghetti allo scoglio', price: 9.0, itemStatus: ItemStatus.inPreparation),
      ],
      status: ItemStatus.inPreparation,
    ),
  ];

  // Aggiungiamo una nuova lista per i singoli piatti pronti per la consegna
  static final List<ReadyItemForDelivery> _readyForDeliveryItems = [];
  static final List<Order> _kitchenArchive = [];
  static final List<Order> _waiterArchive = [];
  
  // Metodo per ottenere tutti gli ordini
  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_allOrders);
  }

  // Metodo per ottenere i singoli piatti pronti per la consegna
  Future<List<ReadyItemForDelivery>> getReadyForDeliveryItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_readyForDeliveryItems);
  }

  // Metodo per ottenere gli ordini archiviati della cucina
  Future<List<Order>> getKitchenArchive() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_kitchenArchive);
  }

  // Metodo per ottenere gli ordini archiviati della sala
  Future<List<Order>> getWaiterArchive() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_waiterArchive);
  }

  // Metodo per segnare un singolo piatto come pronto
  void markItemAsReady(int orderId, String itemName) {
    try {
      final order = _allOrders.firstWhere((o) => o.id == orderId);
      final item = order.items.firstWhere((i) => i.itemName == itemName);
      item.itemStatus = ItemStatus.ready;
      
  // Aggiungiamo il nuovo oggetto ReadyItemForDelivery alla lista
  _readyForDeliveryItems.add(ReadyItemForDelivery(orderId: order.id, item: item, tableNumber: order.tableNumber));
      
      // Controlla se tutti gli elementi dell'ordine sono pronti. Se lo sono, sposta l'ordine nell'archivio della cucina.
      final allItemsReady = order.items.every((item) => item.itemStatus == ItemStatus.ready);
      if (allItemsReady) {
        order.status = ItemStatus.ready;
        _allOrders.removeWhere((o) => o.id == order.id);
        _kitchenArchive.add(order);
      }
    } catch (e) {
      print('Ordine o piatto non trovato: $e');
    }
  }

  // Metodo per segnare un piatto come completato
  void completeItem(int tableNumber, String itemName) {
    try {
      _readyForDeliveryItems.removeWhere((readyItem) => 
        readyItem.tableNumber == tableNumber && readyItem.item.itemName == itemName
      );
    } catch (e) {
      print('Piatto pronto non trovato: $e');
    }
  }

  // Metodo per ripristinare un ordine dall'archivio
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
  orderToRestore.status = ItemStatus.inPreparation;
      _allOrders.add(orderToRestore);
    } else {
      print('Ordine archiviato non trovato: $orderId');
    }
  }
  
  // Metodo per completare un ordine (obsoleto, lo manteniamo per chiarezza)
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

  // Aggiunge un nuovo ordine (usato dalla UI di registrazione cliente)
  Future<void> addOrder(Order order) async {
    // simulate latency
    await Future.delayed(const Duration(milliseconds: 200));
    _allOrders.add(order);
  }
}