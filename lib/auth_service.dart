// lib/auth_service.dart

import 'dart:async';
import 'package:ordinazione_finale/models/staff.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Database fittizio per gli account dello staff
  static final List<Staff> _staffAccounts = [
    Staff(username: 'cuoco', password: 'password', role: 'cook'),
    Staff(username: 'cameriere', password: 'password', role: 'waiter'),
    Staff(username: 'proprietario', password: 'password', role: 'owner'),
  ];

  // Metodo per autenticare l'utente e restituire il suo ruolo
  Future<String?> authenticate(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final staffMember = _staffAccounts.firstWhere(
        (staff) => staff.username == username && staff.password == password,
      );
      return staffMember.role;
    } catch (e) {
      // Credenziali non valide
      return null;
    }
  }
}