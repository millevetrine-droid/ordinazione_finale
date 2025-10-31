import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordinazione/core/services/firebase_service.dart' as core_fb;
import 'dart:developer' as dev;
import 'package:ordinazione/models/cliente_model.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:ordinazione/core/utils/password_utils.dart';

class ClientAuthService {
  final FirebaseFirestore? _injected;

  ClientAuthService([FirebaseFirestore? firestore]) : _injected = firestore;

  FirebaseFirestore get _firestore => _injected ?? core_fb.FirebaseService().firestore;

  // 👇 LOGIN CLIENTE
  Future<Cliente?> loginCliente(String telefono, String password) async {
    try {
      final snapshot = await _firestore
          .collection('clienti')
          .where('telefono', isEqualTo: telefono)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();

      // Prefer password_hash verification if present
      if (data.containsKey('password_hash') && data.containsKey('password_salt')) {
        final storedHash = data['password_hash'] as String;
        final salt = data['password_salt'] as String;
        final iterations = (data['password_iterations'] ?? 100000) as int;
        final dkLen = (data['dk_len'] ?? 32) as int;
        final ok = PasswordUtils.verifyPassword(password, storedHash, salt, iterations, dkLen);
        if (!ok) return null;
        return Cliente.fromMap(data, doc.id);
      }

      // Fallback: legacy plain password field
      if (data['password'] == password) {
        return Cliente.fromMap(data, doc.id);
      }

      return null;
    } catch (e) {
      dev.log('❌ Errore login cliente: $e', name: 'ClientAuthService');
      rethrow;
    }
  }

  // 👇 REGISTRA CLIENTE
  Future<Cliente> registraCliente(
    String nome,
    String cognome,
    String telefono,
    String password,
    int puntiIniziali,
  ) async {
    try {
      // Controlla se il cliente esiste già
      final clienteEsistente = await getClienteByTelefono(telefono);
      if (clienteEsistente != null) {
        throw Exception('Cliente già registrato con questo telefono');
      }

      // hash password
      final hashed = PasswordUtils.hashPassword(password);

      final nuovoCliente = Cliente(
        id: telefono,
        telefono: telefono,
        nome: '$nome $cognome',
        punti: puntiIniziali,
        dataRegistrazione: DateTime.now(),
        ultimoOrdine: DateTime.now(),
        password: null,
      );

      // salva con campi hash/salt/iterations
      final dataToSave = nuovoCliente.toMap();
      dataToSave.addAll({
        'password_hash': hashed['password_hash'],
        'password_salt': hashed['password_salt'],
        'password_iterations': hashed['password_iterations'],
        'dk_len': hashed['dk_len'],
      });

      await _firestore.collection('clienti').doc(telefono).set(dataToSave);
      return nuovoCliente;
    } catch (e) {
      dev.log('❌ Errore registrazione cliente: $e', name: 'ClientAuthService');
      rethrow;
    }
  }

  // 👇 CERCA CLIENTE PER TELEFONO
  Future<Cliente?> getClienteByTelefono(String telefono) async {
    try {
      final snapshot = await _firestore
          .collection('clienti')
          .where('telefono', isEqualTo: telefono)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return Cliente.fromMap(data, snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      dev.log('❌ Errore ricerca cliente: $e', name: 'ClientAuthService');
      rethrow;
    }
  }

  // 👇 AGGIORNA PUNTI CLIENTE
  Future<void> aggiornaPuntiCliente(String telefono, int nuoviPunti) async {
    try {
      final cliente = await getClienteByTelefono(telefono);
      if (cliente != null) {
        final clienteAggiornato = cliente.copyWith(
          punti: nuoviPunti,
          ultimoOrdine: DateTime.now(),
        );
        await salvaCliente(clienteAggiornato);
  dev.log('✅ Punti cliente aggiornati: $telefono -> $nuoviPunti punti', name: 'ClientAuthService');
      }
    } catch (e) {
      dev.log('❌ Errore aggiornamento punti: $e', name: 'ClientAuthService');
      rethrow;
    }
  }

  // 👇 SALVA CLIENTE
  Future<void> salvaCliente(Cliente cliente) async {
    try {
      await _firestore
          .collection('clienti')
          .doc(cliente.telefono)
          .set(cliente.toMap());
  dev.log('✅ Cliente salvato: ${cliente.nome}', name: 'ClientAuthService');
    } catch (e) {
      dev.log('❌ Errore salvataggio cliente: $e', name: 'ClientAuthService');
      rethrow;
    }
  }

  // ===== Password reset token flow =====
  Future<String> generateResetToken(String telefono, {Duration ttl = const Duration(hours:1)}) async {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    final token = base64Url.encode(bytes);

    final tokenHash = sha256.convert(utf8.encode(token)).toString();
    final expiresAt = DateTime.now().toUtc().add(ttl);

    await _firestore.collection('password_resets').doc(telefono).set({
      'token_hash': tokenHash,
      'expires_at': Timestamp.fromDate(expiresAt),
      'telefono': telefono,
      'created_at': FieldValue.serverTimestamp(),
    });

    return token;
  }

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

    await _firestore.collection('password_resets').doc(telefono).delete();
    return true;
  }

  bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var res = 0;
    for (var i = 0; i < a.length; i++) {
      res |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return res == 0;
  }
}