import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ordinazione/core/services/session_service.dart';

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
  String? _sessionId;
  StreamSubscription<SessionData?>? _sessionSub;

  SessioneTavolo? get sessioneCorrente => _sessioneCorrente;
  bool get hasSessioneAttiva => _sessioneCorrente != null;

  void setTavolo(int numeroTavolo) {
    _sessioneCorrente = SessioneTavolo(
      numeroTavolo: numeroTavolo,
      inizioSessione: DateTime.now(),
    );
    notifyListeners();
  }

  /// Start listening to a remote session document. If session becomes inactive
  /// or is deleted, the local session will be cleared automatically.
  void listenToSession(String sessionId) {
    if (_sessionId == sessionId) return;
    _stopListening();
    _sessionId = sessionId;
    _sessionSub = SessionService().sessionStream(sessionId).listen((s) {
      if (s == null || !s.attiva) {
        clearSessione();
        return;
      }
      _sessioneCorrente = SessioneTavolo(
        numeroTavolo: s.numeroTavolo,
        inizioSessione: s.createdAt,
      );
      notifyListeners();
    });
  }

  void _stopListening() {
    _sessionSub?.cancel();
    _sessionSub = null;
    _sessionId = null;
  }

  /// Returns the current remote session id if any
  String? get sessionId => _sessionId;

  /// Ends the current remote session (if any) by calling the SessionService
  /// and clearing local state. Any errors are propagated to the caller.
  Future<void> endCurrentSession() async {
    final id = _sessionId;
    if (id == null) return;
    await SessionService().endSession(id);
    clearSessione();
  }

  void clearSessione() {
    _sessioneCorrente = null;
    _stopListening();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}