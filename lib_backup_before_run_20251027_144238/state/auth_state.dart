import 'package:flutter/foundation.dart';
import '../models/cliente_model.dart';

class AuthState extends ChangeNotifier {
  Cliente? _currentUser;
  
  Cliente? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  
  void login(Cliente user) {
    _currentUser = user;
    notifyListeners();
  }
  
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
  
  void updateUserPoints(int nuoviPunti) {
    if (_currentUser != null) {
      // 👇 CORREZIONE: Usa copyWith() invece di creare nuovo oggetto
      _currentUser = _currentUser!.copyWith(punti: nuoviPunti);
      notifyListeners();
    }
  }
}