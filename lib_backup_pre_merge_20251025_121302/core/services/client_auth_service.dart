import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:ordinazione/core/utils/password_utils.dart';

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

  // ===== Password reset token flow =====
  /// Genera un token sicuro, salva l'hash + expiry in Firestore e ritorna il token
  Future<String> generateResetToken(String telefono, {Duration ttl = const Duration(hours:1)}) async {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    final token = base64Url.encode(bytes);

    final tokenHash = sha256.convert(utf8.encode(token)).toString();
    final expiresAt = DateTime.now().toUtc().add(ttl);

    // Salva l'entry hashed nella collezione password_resets
    await _firestore.collection('password_resets').doc(telefono).set({
      'token_hash': tokenHash,
      'expires_at': Timestamp.fromDate(expiresAt),
      'telefono': telefono,
      'created_at': FieldValue.serverTimestamp(),
    });

    return token;
  }

  /// Verifica che il token fornito corrisponda all'hash salvato e non sia scaduto
  Future<bool> verifyResetToken(String telefono, String token) async {
    final snapshot = await _firestore.collection('password_resets').doc(telefono).get();
    if (!snapshot.exists) return false;
    final data = snapshot.data();
    if (data == null) return false;

    final expiresAt = (data['expires_at'] as Timestamp).toDate();
    if (DateTime.now().toUtc().isAfter(expiresAt)) return false;

    final tokenHash = data['token_hash'] as String?;
    if (tokenHash == null) return false;
    final computed = sha256.convert(utf8.encode(token)).toString();
    return constantTimeEquals(computed, tokenHash);
  }

  /// Imposta una nuova password (hashed) per il cliente identificato dal telefono
  Future<bool> setNewPassword(String telefono, String newPassword) async {

    final hashed = PasswordUtils.hashPassword(newPassword);

    final snapshot = await _firestore.collection('clienti').where('telefono', isEqualTo: telefono).get();
    if (snapshot.docs.isEmpty) return false;

    final docId = snapshot.docs.first.id;
    await _firestore.collection('clienti').doc(docId).update({
      'password_hash': hashed['password_hash'],
      'password_salt': hashed['password_salt'],
      'password_iterations': hashed['password_iterations'],
      'dk_len': hashed['dk_len'],
      'password': FieldValue.delete(),
    });

    // rimuovi eventuale token di reset
    await _firestore.collection('password_resets').doc(telefono).delete();
    return true;
  }

  /// Confronto costante nel tempo per evitare timing attacks
  bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var res = 0;
    for (var i = 0; i < a.length; i++) {
      res |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return res == 0;
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