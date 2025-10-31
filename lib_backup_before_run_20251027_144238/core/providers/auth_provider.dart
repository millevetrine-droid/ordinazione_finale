import 'package:flutter/foundation.dart';

class User {
  final String username;
  final String ruolo; // 'admin', 'cuoco', 'cameriere'
  final String nome;

  User({
    required this.username,
    required this.ruolo,
    required this.nome,
  });

  bool get isProprietario => ruolo == 'admin';
  bool get canGestireTutto => ruolo == 'admin';
}

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  bool get isAdmin => _user?.ruolo == 'admin';
  bool get isCuoco => _user?.ruolo == 'cuoco';
  bool get isCameriere => _user?.ruolo == 'cameriere';
  
  bool get isProprietario => isAdmin;

  // ✅ PERMESSI OPERATIVI
  bool get canGestireOrdini => isAdmin || isCuoco || isCameriere;
  bool get canVedereStatistiche => isAdmin;
  bool get canResetDatabase => isAdmin;
  bool get canGenerareQR => isAdmin || isCameriere;
  bool get canPrendereOrdiniManuali => isAdmin || isCameriere;
  bool get canGestireMenu => isAdmin;
  bool get canRecuperareOrdini => true;
  
  // ✅ PERMESSI AREE
  bool get canGestireCucina => isAdmin || isCuoco;
  bool get canGestireSala => isAdmin || isCameriere;
  bool get canGestireArchivio => isAdmin;
  bool get canGestireCatalogo => isAdmin;
  bool get canVedereTuttiOrdini => isAdmin;
  bool get canGestioneAvanzata => isAdmin;

  // ✅ NUOVO: Permesso specifico per Area Staff
  bool get canAccedereStaff => isAdmin || isCuoco || isCameriere;

  Future<bool> login(String username, String password) async {
    // Credenziali di test - AGGIORNATE
    final users = {
      'admin': User(username: 'admin', ruolo: 'admin', nome: 'Proprietario'),
      'cuoco': User(username: 'cuoco', ruolo: 'cuoco', nome: 'Chef Mario'),
      'cameriere': User(username: 'cameriere', ruolo: 'cameriere', nome: 'Marco'),
    };

    if (users.containsKey(username) && password == '123') {
      _user = users[username];
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  bool hasAccessTo(String functionality) {
    switch (functionality) {
      case 'cucina':
        return canGestireCucina;
      case 'sala':
        return canGestireSala;
      case 'archivio':
        return canGestireArchivio;
      case 'statistiche':
        return canVedereStatistiche;
      case 'gestione_menu':
        return canGestireMenu;
      case 'reset_database':
        return canResetDatabase;
      case 'staff': // ✅ AGGIUNTO
        return canAccedereStaff;
      default:
        return false;
    }
  }
}