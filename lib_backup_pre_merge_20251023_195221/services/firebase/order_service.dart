import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ordine_model.dart';
import 'dart:developer' as dev;

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 👇 METODO OTTIMIZZATO: Caricamento una-tantum
  Future<List<Ordine>> getTuttiOrdiniUnaVolta() async {
    try {
      final snapshot = await _firestore
          .collection('ordini')
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Ordine.fromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      dev.log('❌ Errore caricamento ordini una-tantum: $e', name: 'OrderService');
      rethrow;
    }
  }

  // 👇 METODO ORIGINALE: Stream continuo (mantenuto per compatibilità)
  Stream<List<Ordine>> getTuttiOrdini() {
    return _firestore
        .collection('ordini')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ordine.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Ordine>> getOrdiniByStato(String stato) {
    return _firestore
        .collection('ordini')
        .where('statoComplessivo', isEqualTo: stato)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ordine.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // 👇 METODI PER CUCINA E SALA (esistenti)
  Stream<List<Ordine>> getOrdiniCucina() {
    return _firestore
        .collection('ordini')
        .where('statoComplessivo', whereIn: ['in_attesa', 'in_preparazione'])
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ordine.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Ordine>> getOrdiniSala() {
    return _firestore
        .collection('ordini')
        .where('statoComplessivo', isEqualTo: 'pronto')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ordine.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> salvaOrdine(Ordine ordine) async {
    try {
      final Map<String, dynamic> ordineData = {
        'tavolo': ordine.tavolo,
        'pietanze': ordine.pietanze.map((p) => p.toMap()).toList(),
        'timestamp': FieldValue.serverTimestamp(),
        'numeroPersone': ordine.numeroPersone,
        'telefonoCliente': ordine.telefonoCliente,
        'nomeCliente': ordine.nomeCliente,
        'accumulaPunti': ordine.accumulaPunti,
        'statoComplessivo': ordine.statoComplessivo,
      };
      
      await _firestore.collection('ordini').doc(ordine.id).set(ordineData);
    } catch (e) {
      dev.log('❌ Errore salvataggio ordine: $e', name: 'OrderService');
      rethrow;
    }
  }

  // 👇 METODO PER MENU SCREEN (esistente)
  Future<void> salvaOrdineMenu(Ordine ordine) async {
    try {
      final Map<String, dynamic> ordineData = {
        'tavolo': ordine.tavolo,
        'pietanze': ordine.pietanze.map((p) => p.toMap()).toList(),
        'timestamp': FieldValue.serverTimestamp(),
        'numeroPersone': ordine.numeroPersone,
        'telefonoCliente': ordine.telefonoCliente,
        'nomeCliente': ordine.nomeCliente,
        'accumulaPunti': ordine.accumulaPunti,
        'statoComplessivo': ordine.statoComplessivo,
      };
      
      await _firestore.collection('ordini').doc(ordine.id).set(ordineData);
    } catch (e) {
      dev.log('❌ Errore salvataggio ordine menu: $e', name: 'OrderService');
      rethrow;
    }
  }

  Future<void> aggiornaStatoOrdine(String ordineId, String nuovoStato) async {
    try {
      await _firestore.collection('ordini').doc(ordineId).update({
        'statoComplessivo': nuovoStato,
        'timestampAggiornamento': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      dev.log('❌ Errore aggiornamento stato ordine: $e', name: 'OrderService');
      rethrow;
    }
  }

  Future<void> aggiornaStatoPietanza(
    String ordineId,
    String pietanzaId,
    String nuovoStato,
  ) async {
    try {
      final ordineDoc = await _firestore.collection('ordini').doc(ordineId).get();
      if (!ordineDoc.exists) {
        throw 'Ordine non trovato';
      }

      final ordine = Ordine.fromFirestore(ordineDoc.id, ordineDoc.data()!);
      final pietanzeAggiornate = ordine.pietanze.map((pietanza) {
        if (pietanza.idPietanza == pietanzaId) {
          return PietanzaOrdine(
            idPietanza: pietanza.idPietanza,
            nome: pietanza.nome,
            prezzo: pietanza.prezzo,
            quantita: pietanza.quantita,
            stato: nuovoStato,
          );
        }
        return pietanza;
      }).toList();

      // Calcola stato complessivo
      final statiPietanze = pietanzeAggiornate.map((p) => p.stato).toSet();
      final String statoComplessivo;
      
      if (statiPietanze.contains('in_preparazione')) {
        statoComplessivo = 'in_preparazione';
      } else if (statiPietanze.every((stato) => stato == 'pronto')) {
        statoComplessivo = 'pronto';
      } else if (statiPietanze.every((stato) => stato == 'consegnato')) {
        statoComplessivo = 'consegnato';
      } else {
        statoComplessivo = 'in_attesa';
      }

      await _firestore.collection('ordini').doc(ordineId).update({
        'pietanze': pietanzeAggiornate.map((p) => p.toMap()).toList(),
        'statoComplessivo': statoComplessivo,
        'timestampAggiornamento': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      dev.log('❌ Errore aggiornamento stato pietanza: $e', name: 'OrderService');
      rethrow;
    }
  }

  Future<void> eliminaOrdine(String ordineId) async {
    try {
      await _firestore.collection('ordini').doc(ordineId).delete();
    } catch (e) {
      dev.log('❌ Errore eliminazione ordine: $e', name: 'OrderService');
      rethrow;
    }
  }

  Future<List<Ordine>> getOrdiniByTavolo(String numeroTavolo) async {
    try {
      final snapshot = await _firestore
          .collection('ordini')
          .where('tavolo', isEqualTo: numeroTavolo)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Ordine.fromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      dev.log('❌ Errore caricamento ordini per tavolo: $e', name: 'OrderService');
      rethrow;
    }
  }

  Future<void> archiviaOrdine(String ordineId) async {
    try {
      await _firestore.collection('ordini').doc(ordineId).update({
        'archiviato': true,
        'timestampArchiviazione': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      dev.log('❌ Errore archiviazione ordine: $e', name: 'OrderService');
      rethrow;
    }
  }

  // 👇 METODO PER CASSA SCREEN (esistente)
  Future<void> archiviaOrdineCompletato(String ordineId) async {
    try {
      await _firestore.collection('ordini').doc(ordineId).update({
        'archiviato': true,
        'timestampArchiviazione': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      dev.log('❌ Errore archiviazione ordine completato: $e', name: 'OrderService');
      rethrow;
    }
  }

  Stream<List<Ordine>> getOrdiniNonArchiviati() {
    return _firestore
        .collection('ordini')
        .where('archiviato', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ordine.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<List<Ordine>> getOrdiniArchiviati() async {
    try {
      final snapshot = await _firestore
          .collection('ordini')
          .where('archiviato', isEqualTo: true)
          .orderBy('timestampArchiviazione', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Ordine.fromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      dev.log('❌ Errore caricamento ordini archiviati: $e', name: 'OrderService');
      rethrow;
    }
  }

  Future<double> getIncassoGiornaliero(DateTime data) async {
    try {
      final inizioGiorno = Timestamp.fromDate(DateTime(data.year, data.month, data.day));
      final fineGiorno = Timestamp.fromDate(DateTime(data.year, data.month, data.day, 23, 59, 59));

      final snapshot = await _firestore
          .collection('ordini')
          .where('timestamp', isGreaterThanOrEqualTo: inizioGiorno)
          .where('timestamp', isLessThanOrEqualTo: fineGiorno)
          .where('statoComplessivo', isEqualTo: 'consegnato')
          .get();

      double totale = 0.0;
      for (final doc in snapshot.docs) {
        final ordine = Ordine.fromFirestore(doc.id, doc.data());
        totale += ordine.totale;
      }
      return totale;
    } catch (e) {
      dev.log('❌ Errore calcolo incasso giornaliero: $e', name: 'OrderService');
      return 0.0;
    }
  }
}