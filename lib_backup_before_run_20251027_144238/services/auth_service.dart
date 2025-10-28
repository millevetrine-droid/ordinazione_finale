import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  String? _userRole;
  bool _isLoggedIn = false;

  String? get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;

  // Credenziali predefinite per testing
  final Map<String, Map<String, String>> _users = {
    'cuoco': {
      'username': 'cuoco',
      'password': '123',
      'role': 'cuoco'
    },
    'cameriere': {
      'username': 'cameriere', 
      'password': '123',
      'role': 'cameriere'
    },
    'proprietario': {
      'username': 'admin',
      'password': '123',
      'role': 'proprietario'
    },
  };

  Future<bool> login(String username, String password) async {
    // Simula un ritardo di rete
    await Future.delayed(const Duration(milliseconds: 500));

    for (final user in _users.values) {
      if (user['username'] == username && user['password'] == password) {
        _isLoggedIn = true;
        _userRole = user['role'];
        notifyListeners();
        return true;
      }
    }
    
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _userRole = null;
    notifyListeners();
  }

  // Verifica i permessi per le varie schermate
  bool hasPermission(String requiredRole) {
    if (_userRole == 'proprietario') return true; // Il proprietario vede tutto
    return _userRole == requiredRole;
  }
}