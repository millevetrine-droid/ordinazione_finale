import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllOrders() {
    return _firestore.collection('ordini').snapshots();
  }

  Future<void> cancelOrder(String tableId) async {
    await _firestore.collection('ordini').doc(tableId).delete();
  }

  Future<void> completeOrder(String tableId) async {
    await _firestore.collection('ordini').doc(tableId).delete();
  }

  Future<void> markOrderAsReady(String tableId) async {
    final orderDoc = _firestore.collection('ordini').doc(tableId);
    await orderDoc.update({'ready': true});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamArchivedOrders() {
    return _firestore.collection('archiviati').snapshots();
  }
  
  Future<void> createOrder(String tableNumber, Map<String, int> items) async {
    await _firestore.collection('ordini').doc(tableNumber).set({
      'items': items,
      'timestamp': FieldValue.serverTimestamp(),
      'ready': false,
    });
  }
}