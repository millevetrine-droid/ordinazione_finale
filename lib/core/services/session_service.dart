import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordinazione/core/services/firebase_service.dart';

class SessionData {
  final String sessionId;
  final String codice;
  final int numeroTavolo;
  final String idCameriere;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool attiva;

  SessionData({
    required this.sessionId,
    required this.codice,
    required this.numeroTavolo,
    required this.idCameriere,
    required this.createdAt,
    this.expiresAt,
    required this.attiva,
  });

  factory SessionData.fromMap(String id, Map<String, dynamic> m) {
    DateTime? parseTs(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return null;
    }

    return SessionData(
      sessionId: id,
      codice: m['codice'] ?? '',
      numeroTavolo: (m['numeroTavolo'] is int) ? m['numeroTavolo'] as int : int.tryParse((m['numeroTavolo'] ?? '').toString()) ?? 0,
      idCameriere: m['idCameriere'] ?? '',
      createdAt: parseTs(m['createdAt']) ?? DateTime.now(),
      expiresAt: parseTs(m['expiresAt']),
      attiva: m['attiva'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'codice': codice,
        'numeroTavolo': numeroTavolo,
        'idCameriere': idCameriere,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'attiva': attiva,
      };
}

class SessionService {
  SessionService._internal();
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;

  final FirebaseFirestore _firestore = FirebaseService().firestore;
  final String _collection = 'sessions';

  Future<String> createSession({
    required int numeroTavolo,
    required String idCameriere,
    Duration ttl = const Duration(hours: 3),
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final codice = 'S-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final now = DateTime.now();
    final expires = now.add(ttl);

    final data = {
      'codice': codice,
      'numeroTavolo': numeroTavolo,
      'idCameriere': idCameriere,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expires),
      'attiva': true,
    };

    await docRef.set(data);
    return docRef.id;
  }

  Future<SessionData?> joinSessionByCode(String codice) async {
    final q = await _firestore.collection(_collection).where('codice', isEqualTo: codice).limit(1).get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    final map = doc.data();
    final s = SessionData.fromMap(doc.id, map);
    if (!s.attiva) return null;
    if (s.expiresAt != null && s.expiresAt!.isBefore(DateTime.now())) return null;
    return s;
  }

  Future<SessionData?> getSessionById(String sessionId) async {
    final doc = await _firestore.collection(_collection).doc(sessionId).get();
    if (!doc.exists) return null;
    return SessionData.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Stream<SessionData?> sessionStream(String sessionId) {
    return _firestore.collection(_collection).doc(sessionId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return SessionData.fromMap(snap.id, snap.data() as Map<String, dynamic>);
    });
  }

  Future<void> endSession(String sessionId) async {
    final docRef = _firestore.collection(_collection).doc(sessionId);
    await docRef.update({'attiva': false, 'expiresAt': Timestamp.fromDate(DateTime.now())});
  }
}
