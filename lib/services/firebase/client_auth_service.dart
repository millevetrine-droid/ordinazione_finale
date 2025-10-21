import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import '../../models/cliente_model.dart';

class ClientAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 👇 LOGIN CLIENTE
  Future<Cliente?> loginCliente(String telefono, String password) async {
    try {
      final snapshot = await _firestore
          .collection('clienti')
          .where('telefono', isEqualTo: telefono)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return Cliente.fromMap(data, snapshot.docs.first.id);
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

      final nuovoCliente = Cliente(
        id: telefono,
        telefono: telefono,
        nome: '$nome $cognome',
        punti: puntiIniziali,
        dataRegistrazione: DateTime.now(),
        ultimoOrdine: DateTime.now(),
        password: password,
      );

      await salvaCliente(nuovoCliente);
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
}