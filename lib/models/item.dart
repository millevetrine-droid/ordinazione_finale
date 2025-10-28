// lib/models/item.dart

class ItemStatus {
  static const String inPreparation = 'In preparazione';
  static const String ready = 'In consegna';
}

class Item {
  final String itemName;
  final double? price;
  String itemStatus;

  Item({
    required this.itemName,
    this.price,
    required this.itemStatus,
  });
}
