// lib/models/order.dart

import 'package:flutter/material.dart';
import 'package:ordinazione/models/item.dart';

class Order {
  final int id;
  final int tableNumber;
  final List<Item> items;
  String status;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.status,
  });
}

// Nuovo modello per i piatti pronti per la consegna
class ReadyItemForDelivery {
  final int orderId;
  final Item item;
  final int tableNumber;

  ReadyItemForDelivery({
    required this.orderId,
    required this.item,
    required this.tableNumber,
  });
}