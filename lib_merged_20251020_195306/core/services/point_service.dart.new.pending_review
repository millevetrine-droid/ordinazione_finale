import 'package:cloud_firestore/cloud_firestore.dart';

class PointsService {
  final FirebaseFirestore _firestore;

  PointsService(this._firestore);

  Future<Map<String, dynamic>> regalaPunti({
    required String daTelefono,
    required String aTelefono,
    required int punti,
    String? messaggio,
  }) async {
    try {
      final mittenteSnapshot = await _firestore.collection('clienti')
          .where('telefono', isEqualTo: daTelefono)
          .get();

      if (mittenteSnapshot.docs.isEmpty) {
        return {'success': false, 'error': 'Mittente non trovato'};
      }

      final mittenteData = mittenteSnapshot.docs.first.data();
      final puntiMittente = mittenteData['punti'] ?? 0;

      if (puntiMittente < punti) {
        return {'success': false, 'error': 'Punti insufficienti'};
      }

      final destinatarioSnapshot = await _firestore.collection('clienti')
          .where('telefono', isEqualTo: aTelefono)
          .get();

      if (destinatarioSnapshot.docs.isEmpty) {
        return {'success': false, 'error': 'Destinatario non trovato'};
      }

      final batch = _firestore.batch();

      batch.update(mittenteSnapshot.docs.first.reference, {
        'punti': FieldValue.increment(-punti)
      });

      batch.update(destinatarioSnapshot.docs.first.reference, {
        'punti': FieldValue.increment(punti)
      });

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

      return {'success': true, 'messaggio': 'Punti regalati con successo'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Stream<List<Map<String, dynamic>>> getRegaliInviati(String telefono) {
    return _firestore.collection('regaliPunti')
        .where('daTelefono', isEqualTo: telefono)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getRegaliRicevuti(String telefono) {
    return _firestore.collection('regaliPunti')
        .where('aTelefono', isEqualTo: telefono)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> aggiungiPunti(String telefono, int punti) async {
    final snapshot = await _firestore.collection('clienti')
        .where('telefono', isEqualTo: telefono)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await _firestore.collection('clienti').doc(snapshot.docs.first.id).update({
        'punti': FieldValue.increment(punti),
      });
    }
  }
}
