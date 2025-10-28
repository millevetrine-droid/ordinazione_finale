import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordinazione/core/services/firebase_service.dart' as core_fb;
import 'client_auth_service.dart';
import 'package:ordinazione/models/cliente_model.dart'; // 👈 CORRETTO IMPORT
import 'dart:developer' as dev;

class PointsService {
  FirebaseFirestore get _firestore => core_fb.FirebaseService().firestore;
  final ClientAuthService clientAuth = ClientAuthService();

  // 👇 REGALA PUNTI
  Future<Map<String, dynamic>> regalaPunti({
    required String daTelefono,
    required String aTelefono,
    required int punti,
    String? messaggio,
  }) async {
    try {
      // Verifica clienti
      final clienteMittente = await clientAuth.getClienteByTelefono(daTelefono);
      final clienteDestinatario = await clientAuth.getClienteByTelefono(aTelefono);

      if (clienteMittente == null) {
        return {'success': false, 'error': 'Mittente non trovato'};
      }
      if (clienteDestinatario == null) {
        return {'success': false, 'error': 'Destinatario non trovato'};
      }
      if (clienteMittente.punti < punti) {
        return {'success': false, 'error': 'Punti insufficienti'};
      }
      if (daTelefono == aTelefono) {
        return {'success': false, 'error': 'Non puoi regalare punti a te stesso'};
      }

      // Aggiorna punti
      final mittenteAggiornato = clienteMittente.copyWith(
        punti: clienteMittente.punti - punti,
      );
      final destinatarioAggiornato = clienteDestinatario.copyWith(
        punti: clienteDestinatario.punti + punti,
      );

      await clientAuth.salvaCliente(mittenteAggiornato);
      await clientAuth.salvaCliente(destinatarioAggiornato);

      // Registra il regalo
      final regaloData = {
        'daTelefono': daTelefono,
        'aTelefono': aTelefono,
        'punti': punti,
        'messaggio': messaggio,
        'timestamp': Timestamp.now(),
      };

      await _firestore.collection('regali_punti').add(regaloData);

      return {
        'success': true,
        'messaggio': '✅ $punti punti regalati a ${clienteDestinatario.nome}!',
      };
    } catch (e) {
      dev.log('❌ Errore regalaPunti: $e', name: 'PointsService');
      return {'success': false, 'error': 'Errore: $e'};
    }
  }

  // 👇 STREAM REGALI INVIATI
  Stream<List<Map<String, dynamic>>> getRegaliInviati(String telefono) {
    return _firestore
        .collection('regali_punti')
        .where('daTelefono', isEqualTo: telefono)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'aTelefono': data['aTelefono'],
          'punti': data['punti'],
          'messaggio': data['messaggio'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    });
  }

  // 👇 STREAM REGALI RICEVUTI
  Stream<List<Map<String, dynamic>>> getRegaliRicevuti(String telefono) {
    return _firestore
        .collection('regali_punti')
        .where('aTelefono', isEqualTo: telefono)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'daTelefono': data['daTelefono'],
          'punti': data['punti'],
          'messaggio': data['messaggio'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    });
  }

  // 👇 AGGIUNGIAMO METODI PER COMPATIBILITÀ
  Future<void> aggiornaPuntiCliente(String telefono, int nuoviPunti) async {
    try {
      await clientAuth.aggiornaPuntiCliente(telefono, nuoviPunti);
    } catch (e) {
      dev.log('❌ Errore aggiornamento punti: $e', name: 'PointsService');
      rethrow;
    }
  }

  Future<Cliente?> getClienteByTelefono(String telefono) async {
    try {
      return await clientAuth.getClienteByTelefono(telefono);
    } catch (e) {
      dev.log('❌ Errore recupero cliente: $e', name: 'PointsService');
      return null;
    }
  }
}