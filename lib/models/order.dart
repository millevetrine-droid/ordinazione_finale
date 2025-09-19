// lib/models/order.dart

import 'package:flutter/material.dart';

class Order {
  final int id;
  final int tableNumber;
  final List<OrderItem> items;
  String status;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.status,
  });
}

class OrderItem {
  final String itemName;
  String itemStatus;

  OrderItem({
    required this.itemName,
    required this.itemStatus,
  });
}

// Nuovo modello per i piatti pronti per la consegna
class ReadyItemForDelivery {
  final OrderItem item;
  final int tableNumber;

  ReadyItemForDelivery({
    required this.item,
    required this.tableNumber,
  });
}