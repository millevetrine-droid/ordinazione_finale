import 'package:cloud_firestore/cloud_firestore.dart';

class ArchiveService {
  final FirebaseFirestore _firestore;

  ArchiveService(this._firestore);

  Stream<List<Map<String, dynamic>>> getArchivioCucina() {
    return _firestore.collection('archivioCucina')
      .orderBy('data_archiviazione', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getArchivioSala() {
    return _firestore.collection('archivioSala')
      .orderBy('data_archiviazione', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getTransazioni() {
    return _firestore.collection('transazioni')
      .orderBy('data', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'tavolo': data['tavolo'] ?? '',
          'importo': (data['importo'] ?? 0.0).toDouble(),
          'metodoPagamento': data['metodoPagamento'] ?? 'contanti',
          'data': (data['data'] is Timestamp) ? (data['data'] as Timestamp).toDate() : data['data'],
          'note': data['note'] ?? '',
        };
      }).toList());
  }

  Future<void> registraPagamento({
    required String tavolo,
    required double importo,
    required String metodoPagamento,
    required List<Map<String, dynamic>> pietanze,
    String? note,
  }) async {
    await _firestore.collection('transazioni').add({
      'tavolo': tavolo,
      'importo': importo,
      'metodoPagamento': metodoPagamento,
      'pietanze': pietanze,
      'note': note,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ripristinaPietanzaDaArchivio(String archivioId) async {
    await _firestore.collection('archivioCucina').doc(archivioId).delete();
  }

  Future<void> ripristinaPietanzaDaArchivioSala(String archivioId) async {
    await _firestore.collection('archivioSala').doc(archivioId).delete();
  }

  Future<void> archiviaOrdineCompletato(Map<String, dynamic> ordine) async {
    await _firestore.collection('archivioOrdini').add({
      ...ordine,
      'dataArchiviazione': FieldValue.serverTimestamp(),
    });
  }

  // Compatibility shims for legacy callers (keeps old method names)
  Future<void> archiviaPietanzaPronta({
    required String ordineId,
    required int indicePietanza,
    required Map<String, dynamic> pietanza,
    required String tavolo,
  }) async {
    // map to archiviaOrdineCompletato or write into cucina archive collection
    await _firestore.collection('archivioCucina').add({
      'ordineId': ordineId,
      'indice': indicePietanza,
      'pietanza': pietanza,
      'tavolo': tavolo,
      'data_archiviazione': FieldValue.serverTimestamp(),
    });
  }

  Future<void> archiviaPietanzaConsegnata({
    required String ordineId,
    required int indicePietanza,
    required Map<String, dynamic> pietanza,
    required String tavolo,
  }) async {
    await _firestore.collection('archivioSala').add({
      'ordineId': ordineId,
      'indice': indicePietanza,
      'pietanza': pietanza,
      'tavolo': tavolo,
      'data_archiviazione': FieldValue.serverTimestamp(),
    });
  }
}
