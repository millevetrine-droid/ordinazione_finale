// lib/customer_service.dart

import 'dart:async';
import 'package:ordinazione_finale/models/customer.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();

  factory CustomerService() {
    return _instance;
  }

  CustomerService._internal();

  // Database fittizio dei clienti
  static final List<Customer> _customers = [
    Customer(phoneNumber: '1234567890', name: 'Anselmo', points: 100.0),
    Customer(phoneNumber: '0987654321', name: 'Monica', points: 50.0),
  ];

  // Metodo per trovare un cliente tramite numero di telefono e nome
  Future<Customer?> getCustomer(String phoneNumber, String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final customer = _customers.firstWhere(
        (c) => c.phoneNumber == phoneNumber && c.name.toLowerCase() == name.toLowerCase(),
      );
      return customer;
    } catch (e) {
      return null;
    }
  }

  // Metodo per aggiungere un nuovo cliente
  Future<Customer> addCustomer(String phoneNumber, String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newCustomer = Customer(phoneNumber: phoneNumber, name: name);
    _customers.add(newCustomer);
    return newCustomer;
  }

  // Metodo per aggiornare i punti di un cliente
  void addPoints(String phoneNumber, String name, double points) {
    try {
      final customer = _customers.firstWhere(
        (c) => c.phoneNumber == phoneNumber && c.name.toLowerCase() == name.toLowerCase(),
      );
      customer.points += points;
      print('Punti aggiunti a ${customer.name}. Totale: ${customer.points}');
    } catch (e) {
      print('Cliente non trovato.');
    }
  }
}