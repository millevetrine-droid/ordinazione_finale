import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamOrder(int tableNumber) {
    return _ordersCollection.doc(tableNumber.toString()).snapshots()
        as Stream<DocumentSnapshot<Map<String, dynamic>>>;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllOrders() {
    return _ordersCollection.where('is_active', isEqualTo: true).snapshots()
        as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamArchivedOrders() {
    return _ordersCollection.where('is_active', isEqualTo: false).snapshots()
        as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }

  Future<void> updateOrder(String tableId, Map<String, dynamic> updatedData) async {
    updatedData['is_active'] = true;
    await _ordersCollection.doc(tableId).set(updatedData, SetOptions(merge: true));
  }

  Future<void> completeOrder(String tableId) async {
    await _ordersCollection.doc(tableId).update({'is_active': false});
  }

  Future<void> cancelOrder(String tableId) async {
    await _ordersCollection.doc(tableId).update({'is_active': false});
  }
}