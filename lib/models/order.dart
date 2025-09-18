// lib/models/order.dart

class Order {
  final int id;
  final String customerName;
  String status;
  // Aggiungi qui altre proprietà del tuo ordine, come prodotti, prezzi, ecc.

  Order({
    required this.id,
    required this.customerName,
    required this.status,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      customerName: map['customerName'],
      status: map['status'],
    );
  }
}