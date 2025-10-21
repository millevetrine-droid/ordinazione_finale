import 'package:cloud_firestore/cloud_firestore.dart';

class ClientAuthService {
  final FirebaseFirestore _firestore;

  ClientAuthService(this._firestore);

  // CORREZIONE: Sostituito Cliente con Map<String, dynamic>
  Future<Map<String, dynamic>?> getClienteByTelefono(String telefono) async {
    try {
      final snapshot = await _firestore.collection('clienti')
        .where('telefono', isEqualTo: telefono)
        .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final data = snapshot.docs.first.data();
      return {
        'id': snapshot.docs.first.id,
        'nome': data['nome'] ?? '',
        'telefono': data['telefono'] ?? '',
        'punti': data['punti'] ?? 0,
        'dataRegistrazione': (data['dataRegistrazione'] as Timestamp?)?.toDate() ?? DateTime.now(),
      };
    } catch (e) {
      return null;
    }
  }

  // CORREZIONE: Accetta Map<String, dynamic> invece di Cliente
  Future<void> registraCliente(Map<String, dynamic> cliente) async {
    await _firestore.collection('clienti').doc(cliente['id']).set({
      'nome': cliente['nome'],
      'telefono': cliente['telefono'],
      'punti': cliente['punti'] ?? 0,
      'dataRegistrazione': FieldValue.serverTimestamp(),
    });
  }

  Future<void> aggiornaPuntiCliente(String telefono, int nuoviPunti) async {
    final snapshot = await _firestore.collection('clienti')
      .where('telefono', isEqualTo: telefono)
      .get();
    
    if (snapshot.docs.isNotEmpty) {
      await _firestore.collection('clienti').doc(snapshot.docs.first.id).update({
        'punti': nuoviPunti,
      });
    }
  }

  // CORREZIONE: Accetta Map<String, dynamic> invece di Cliente
  Future<void> aggiornaProfiloCliente(Map<String, dynamic> cliente) async {
    await _firestore.collection('clienti').doc(cliente['id']).update({
      'nome': cliente['nome'],
      'telefono': cliente['telefono'],
    });
  }
}