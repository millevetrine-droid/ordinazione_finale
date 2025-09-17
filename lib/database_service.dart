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
    return _ordersCollection.snapshots()
        as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }

  Future<void> updateOrder(String tableId, Map<String, dynamic> updatedData) async {
    await _ordersCollection.doc(tableId).set(updatedData, SetOptions(merge: true));
  }
}