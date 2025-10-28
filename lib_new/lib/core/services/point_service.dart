import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import 'package:ordinazione/core/services/client_auth_service.dart';

/// Consolidated PointsService for `lib_new`.
/// - Uses `ClientAuthService` for client lookups and point updates.
/// - Writes gifts to `regaliPunti` (new schema) and exposes streams compatible
///   with the UI in `lib_new`.
class PointsService {
  final FirebaseFirestore _firestore;
  late final ClientAuthService _clientAuth;

  PointsService(this._firestore) {
    _clientAuth = ClientAuthService(_firestore);
  }

  /// Regala punti da un numero a un altro usando batch per garantire atomicità.
  /// Restituisce una mappa con 'success' true/false e messaggio o errore.
  Future<Map<String, dynamic>> regalaPunti({
    required String daTelefono,
    required String aTelefono,
    required int punti,
    String? messaggio,
  }) async {
    try {
      // Usa ClientAuthService per recuperare i clienti (compatibile con lib_new)
      final mittente = await _clientAuth.getClienteByTelefono(daTelefono);
      final destinatario = await _clientAuth.getClienteByTelefono(aTelefono);

      if (mittente == null) return {'success': false, 'error': 'Mittente non trovato'};
      if (destinatario == null) return {'success': false, 'error': 'Destinatario non trovato'};
      final puntiMittente = mittente['punti'] ?? 0;
      if (puntiMittente < punti) return {'success': false, 'error': 'Punti insufficienti'};
      if (daTelefono == aTelefono) return {'success': false, 'error': 'Non puoi regalare punti a te stesso'};

      final batch = _firestore.batch();

      final mittenteRef = _firestore.collection('clienti').doc(mittente['id']);
      final destinatarioRef = _firestore.collection('clienti').doc(destinatario['id']);

      batch.update(mittenteRef, {'punti': FieldValue.increment(-punti)});
      batch.update(destinatarioRef, {'punti': FieldValue.increment(punti)});

      final regaloRef = _firestore.collection('regaliPunti').doc();
      batch.set(regaloRef, {
        'id': regaloRef.id,
        'daTelefono': daTelefono,
        'aTelefono': aTelefono,
        'punti': punti,
        'messaggio': messaggio,
        'data': FieldValue.serverTimestamp(),
        'stato': 'completato',
      });

      await batch.commit();

      return {'success': true, 'messaggio': '✅ $punti punti regalati con successo'};
    } catch (e) {
      dev.log('❌ Errore regalaPunti: $e', name: 'PointsService');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Stream dei regali inviati (normalizza la shape dei documenti)
  Stream<List<Map<String, dynamic>>> getRegaliInviati(String telefono) {
    return _firestore
        .collection('regaliPunti')
        .where('daTelefono', isEqualTo: telefono)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Stream dei regali ricevuti
  Stream<List<Map<String, dynamic>>> getRegaliRicevuti(String telefono) {
    return _firestore
        .collection('regaliPunti')
        .where('aTelefono', isEqualTo: telefono)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Aggiunge punti ad un cliente (utilizzato in alcune operazioni di admin)
  Future<void> aggiungiPunti(String telefono, int punti) async {
    final snapshot = await _firestore.collection('clienti').where('telefono', isEqualTo: telefono).get();
    if (snapshot.docs.isNotEmpty) {
      await _firestore.collection('clienti').doc(snapshot.docs.first.id).update({
        'punti': FieldValue.increment(punti),
      });
    }
  }

  /// Delegato al ClientAuthService per aggiornare punti a valore assoluto
  Future<void> aggiornaPuntiCliente(String telefono, int nuoviPunti) async {
    await _clientAuth.aggiornaPuntiCliente(telefono, nuoviPunti);
  }

  /// Helper per ottenere il cliente (Map) tramite ClientAuthService
  Future<Map<String, dynamic>?> getClienteByTelefono(String telefono) async {
    return await _clientAuth.getClienteByTelefono(telefono);
  }
}