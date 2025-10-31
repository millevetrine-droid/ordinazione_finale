import 'package:flutter/foundation.dart';

class SessioneTavolo {
  final int numeroTavolo;
  final DateTime inizioSessione;

  SessioneTavolo({
    required this.numeroTavolo,
    required this.inizioSessione,
  });
}

class SessionProvider with ChangeNotifier {
  SessioneTavolo? _sessioneCorrente;

  SessioneTavolo? get sessioneCorrente => _sessioneCorrente;
  bool get hasSessioneAttiva => _sessioneCorrente != null;

  void setTavolo(int numeroTavolo) {
    _sessioneCorrente = SessioneTavolo(
      numeroTavolo: numeroTavolo,
      inizioSessione: DateTime.now(),
    );
    notifyListeners();
  }

  void clearSessione() {
    _sessioneCorrente = null;
    notifyListeners();
  }
}