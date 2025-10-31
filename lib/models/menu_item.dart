// lib/models/menu_item.dart

import 'package:flutter/material.dart';

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
}