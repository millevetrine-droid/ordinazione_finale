import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import '../../models/pietanza_ordine_model.dart';
import '../../models/transazione_model.dart';

class ArchiveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 👇 ARCHIVIA PIETANZA PRONTA (CUCINA)
  Future<void> archiviaPietanzaPronta({
    required String ordineId,
    required int indicePietanza,
    required Map<String, dynamic> pietanza,
    required String tavolo,
  }) async {
    try {
      final archivioData = {
        'ordine_id': ordineId,
        'indice_pietanza': indicePietanza,
        'pietanza': pietanza,
        'tavolo': tavolo,
        'data_archiviazione': Timestamp.now(),
        'tipo': 'cucina',
      };

  await _firestore.collection('archivio_cucina').add(archivioData);
  dev.log('✅ Pietanza archiviata in cucina', name: 'ArchiveService');
    } catch (e) {
  dev.log('❌ Errore archiviazione cucina: $e', name: 'ArchiveService');
      rethrow;
    }
  }

  // 👇 ARCHIVIA PIETANZA CONSEGNATA (SALA)
  Future<void> archiviaPietanzaConsegnata({
    required String ordineId,
    required int indicePietanza,
    required Map<String, dynamic> pietanza,
    required String tavolo,
  }) async {
    try {
      final archivioData = {
        'ordine_id': ordineId,
        'indice_pietanza': indicePietanza,
        'pietanza': pietanza,
        'tavolo': tavolo,
        'data_archiviazione': Timestamp.now(),
        'tipo': 'sala',
      };

  await _firestore.collection('archivio_sala').add(archivioData);
  dev.log('✅ Pietanza archiviata in sala', name: 'ArchiveService');
    } catch (e) {
  dev.log('❌ Errore archiviazione sala: $e', name: 'ArchiveService');
      rethrow;
    }
  }

  // 👇 STREAM ARCHIVIO CUCINA
  Stream<List<Map<String, dynamic>>> getArchivioCucina() {
    return _firestore
        .collection('archivio_cucina')
        .orderBy('data_archiviazione', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'pietanza': PietanzaOrdine.fromMap(Map<String, dynamic>.from(data['pietanza'])),
          'tavolo': data['tavolo'],
          'data_archiviazione': data['data_archiviazione'],
        };
      }).toList();
    });
  }

  // 👇 STREAM ARCHIVIO SALA
  Stream<List<Map<String, dynamic>>> getArchivioSala() {
    return _firestore
        .collection('archivio_sala')
        .orderBy('data_archiviazione', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'pietanza': PietanzaOrdine.fromMap(Map<String, dynamic>.from(data['pietanza'])),
          'tavolo': data['tavolo'],
          'data_archiviazione': data['data_archiviazione'],
        };
      }).toList();
    });
  }

  // 👇 RIPRISTINA PIETANZA DA ARCHIVIO CUCINA
  Future<void> ripristinaPietanzaDaArchivio(String archivioId) async {
    try {
  await _firestore.collection('archivio_cucina').doc(archivioId).delete();
  dev.log('✅ Pietanza ripristinata da archivio cucina', name: 'ArchiveService');
    } catch (e) {
  dev.log('❌ Errore ripristino archivio cucina: $e', name: 'ArchiveService');
      rethrow;
    }
  }

  // 👇 RIPRISTINA PIETANZA DA ARCHIVIO SALA
  Future<void> ripristinaPietanzaDaArchivioSala(String archivioId) async {
    try {
  await _firestore.collection('archivio_sala').doc(archivioId).delete();
  dev.log('✅ Pietanza ripristinata da archivio sala', name: 'ArchiveService');
    } catch (e) {
  dev.log('❌ Errore ripristino archivio sala: $e', name: 'ArchiveService');
      rethrow;
    }
  }

  // 👇 REGISTRA PAGAMENTO
  Future<void> registraPagamento({
    required String tavolo,
    required double importo,
    required String metodoPagamento,
    required List<Map<String, dynamic>> pietanze,
    String? note,
  }) async {
    try {
      final transazioneData = {
        'tavolo': tavolo,
        'importo': importo,
        'metodo_pagamento': metodoPagamento,
        'pietanze': pietanze,
        'note': note,
        'data': Timestamp.now(),
      };

  await _firestore.collection('transazioni').add(transazioneData);
  dev.log('✅ Pagamento registrato: Tavolo $tavolo - €$importo', name: 'ArchiveService');
    } catch (e) {
  dev.log('❌ Errore registrazione pagamento: $e', name: 'ArchiveService');
      rethrow;
    }
  }

  // 👇 STREAM TRANSAZIONI
  Stream<List<Transazione>> getTransazioni() {
    return _firestore
        .collection('transazioni')
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Transazione.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }
}