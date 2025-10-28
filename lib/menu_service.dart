// lib/menu_service.dart

import 'dart:async';
import 'package:ordinazione/models/menu_item.dart';

class MenuService {
  static final MenuService _instance = MenuService._internal();

  factory MenuService() {
    return _instance;
  }

  MenuService._internal();

  static final List<MenuItem> _menuItems = [
    MenuItem(id: '1', name: 'Pizza Margherita', price: 8.00, category: 'Pizze'),
    MenuItem(id: '2', name: 'Spaghetti allo Scoglio', price: 15.00, category: 'Primi'),
    MenuItem(id: '3', name: 'Bistecca alla Fiorentina', price: 25.00, category: 'Secondi'),
    MenuItem(id: '4', name: 'Tiramisù', price: 6.00, category: 'Dolci'),
    MenuItem(id: '5', name: 'Coca-Cola', price: 3.50, category: 'Bevande'),
    MenuItem(id: '6', name: 'Acqua Naturale', price: 2.00, category: 'Bevande'),
  ];

  Future<List<MenuItem>> getMenuItems() async {
    // Simula una chiamata asincrona al database
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_menuItems);
  }
}