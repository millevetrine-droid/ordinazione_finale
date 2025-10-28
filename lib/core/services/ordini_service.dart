/// FILE: [lib/core/services/ordini_service.dart]
/// SCOPO: [Gestione completa ordini su Firestore con salvataggio persistente]
/// RELAZIONI: 
///   - Importa: [dart:async, cloud_firestore, ordine_model.dart, pietanza_model.dart]
///   - Collegato a: [OrdiniProvider per sincronizzazione tempo reale]
///   - Dipendenze: [FirebaseFirestore, modelli Ordine/Pietanza, StreamSubscription]
/// FUNZIONALITÀ: [Salvataggio ordini, stream tempo reale, aggiornamento stati]
/// MODIFICHE: [Aggiunti import mancanti, corretto modello Ordine, adattato alla struttura esistente]
/// DA VERIFICARE: [Connessione Firebase, salvataggio ordini, sincronizzazione stati]
library;

import 'dart:async'; // ✅ AGGIUNTO PER StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ordinazione/core/models/ordine_model.dart';
import 'package:ordinazione/core/models/pietanza_model.dart'; // ✅ AGGIUNTO

class OrdiniService {
  final FirebaseFirestore _firestore;

  OrdiniService(this._firestore);

  // ✅ SALVATAGGIO ORDINE SU FIRESTORE
  Future<void> salvaOrdine(Ordine ordine) async {
    try {
  debugPrint('🔄 Salvando ordine ${ordine.id} su Firestore...');
      
      await _firestore.collection('ordini').doc(ordine.id).set({
        'id': ordine.id,
        'numeroTavolo': ordine.numeroTavolo,
        'timestamp': FieldValue.serverTimestamp(),
        'stato': _statoOrdineToString(ordine.stato),
        'pietanze': ordine.pietanze.map((p) => _pietanzaToMap(p)).toList(),
        'storicoStati': ordine.storicoStati.map((s) => _statoChangeToMap(s)).toList(),
        'totale': _calcolaTotaleOrdine(ordine.pietanze),
        'idCameriere': ordine.idCameriere, // ✅ CORRETTO: usato idCameriere invece di clienteId
        'note': ordine.note,
      });
      
  debugPrint('✅ Ordine ${ordine.id} salvato con successo!');
    } catch (e) {
  debugPrint('❌ Errore salvataggio ordine: $e');
      throw Exception('Errore nel salvataggio ordine: $e');
    }
  }

  // ✅ STREAM ORDINI IN TEMPO REALE
  Stream<List<Ordine>> getOrdiniStream() {
    return _firestore
        .collection('ordini')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return _documentToOrdine(doc);
            }).toList());
  }

  // ✅ AGGIORNAMENTO STATO ORDINE
  Future<void> aggiornaStatoOrdine(String ordineId, StatoOrdine nuovoStato, String user) async {
    try {
      final statoString = _statoOrdineToString(nuovoStato);
      
      await _firestore.collection('ordini').doc(ordineId).update({
        'stato': statoString,
        'storicoStati': FieldValue.arrayUnion([{
          'fromStato': await _getCurrentStatoString(ordineId),
          'toStato': statoString,
          // Use client timestamp here to avoid nested serverTimestamp in arrayUnion
          'timestamp': Timestamp.now(),
          'user': user,
        }]),
      });
      
  debugPrint('✅ Stato ordine $ordineId aggiornato a: $statoString');
    } catch (e) {
  debugPrint('❌ Errore aggiornamento stato ordine: $e');
      throw Exception('Errore nell\'aggiornamento stato ordine: $e');
    }
  }

  // ✅ AGGIORNAMENTO STATO SINGOLA PIETANZA
  Future<void> aggiornaStatoPietanza({
    required String ordineId,
    required String pietanzaId,
    required StatoPietanza nuovoStato,
    required String user,
  }) async {
    try {
      final doc = await _firestore.collection('ordini').doc(ordineId).get();
      if (!doc.exists) {
        throw Exception('Ordine non trovato: $ordineId');
      }

      final data = doc.data()!;
      final pietanze = List<Map<String, dynamic>>.from(data['pietanze']);
      final pietanzaIndex = pietanze.indexWhere((p) => p['id'] == pietanzaId);
      
      if (pietanzaIndex == -1) {
        throw Exception('Pietanza non trovata: $pietanzaId');
      }

      // Salva vecchio stato per storico
      final vecchioStato = pietanze[pietanzaIndex]['stato'];
      pietanze[pietanzaIndex]['stato'] = _statoPietanzaToString(nuovoStato);

      await _firestore.collection('ordini').doc(ordineId).update({
        'pietanze': pietanze,
        'storicoStati': FieldValue.arrayUnion([{
          'fromStato': vecchioStato,
          'toStato': _statoPietanzaToString(nuovoStato),
          // Use client timestamp here to avoid nested serverTimestamp in arrayUnion
          'timestamp': Timestamp.now(),
          'user': user,
          'pietanzaId': pietanzaId,
          'tipo': 'pietanza',
        }]),
      });

  debugPrint('✅ Stato pietanza $pietanzaId aggiornato a: ${_statoPietanzaToString(nuovoStato)}');
    } catch (e) {
  debugPrint('❌ Errore aggiornamento stato pietanza: $e');
      throw Exception('Errore nell\'aggiornamento stato pietanza: $e');
    }
  }

  // ✅ ELIMINA ORDINE
  Future<void> eliminaOrdine(String ordineId) async {
    try {
      await _firestore.collection('ordini').doc(ordineId).delete();
  debugPrint('✅ Ordine $ordineId eliminato');
    } catch (e) {
  debugPrint('❌ Errore eliminazione ordine: $e');
      throw Exception('Errore nell\'eliminazione ordine: $e');
    }
  }

  // ✅ METODI PRIVATI DI CONVERSIONE
  Map<String, dynamic> _pietanzaToMap(Pietanza pietanza) {
    return {
      'id': pietanza.id,
      'nome': pietanza.nome,
      'descrizione': pietanza.descrizione,
      'prezzo': pietanza.prezzo,
      'emoji': pietanza.emoji,
      'stato': _statoPietanzaToString(pietanza.stato),
      'categoriaId': pietanza.categoriaId,
      'macrocategoriaId': pietanza.macrocategoriaId,
    };
  }

  Map<String, dynamic> _statoChangeToMap(StatoChange statoChange) {
    return {
      'fromStato': _statoOrdineToString(statoChange.fromStato),
      'toStato': _statoOrdineToString(statoChange.toStato),
      'timestamp': statoChange.timestamp,
      'user': statoChange.user,
    };
  }

  Ordine _documentToOrdine(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Ordine(
      id: doc.id,
      numeroTavolo: data['numeroTavolo'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      stato: _stringToStatoOrdine(data['stato']),
      pietanze: (data['pietanze'] as List).map((p) => Pietanza(
        id: p['id'] ?? '',
        nome: p['nome'] ?? '',
        descrizione: p['descrizione'] ?? '',
        prezzo: (p['prezzo'] ?? 0.0).toDouble(),
        emoji: p['emoji'],
        stato: _stringToStatoPietanza(p['stato']),
        categoriaId: p['categoriaId'],
        macrocategoriaId: p['macrocategoriaId'] ?? '',
      )).toList(),
      idCameriere: data['idCameriere'] ?? '', // ✅ CORRETTO: usato idCameriere
      note: data['note'] ?? '',
      storicoStati: (data['storicoStati'] as List? ?? []).map((s) => StatoChange(
        fromStato: _stringToStatoOrdine(s['fromStato']),
        toStato: _stringToStatoOrdine(s['toStato']),
        timestamp: (s['timestamp'] as Timestamp).toDate(),
        user: s['user'] ?? '',
      )).toList(),
    );
  }

  String _statoOrdineToString(StatoOrdine stato) {
    return stato.toString().split('.').last;
  }

  String _statoPietanzaToString(StatoPietanza stato) {
    return stato.toString().split('.').last;
  }

  StatoOrdine _stringToStatoOrdine(String stato) {
    switch (stato) {
      case 'inAttesa': return StatoOrdine.inAttesa;
      case 'inPreparazione': return StatoOrdine.inPreparazione;
      case 'pronto': return StatoOrdine.pronto;
      case 'servito': return StatoOrdine.servito;
      case 'completato': return StatoOrdine.completato;
      default: return StatoOrdine.inAttesa;
    }
  }

  StatoPietanza _stringToStatoPietanza(String stato) {
    switch (stato) {
      case 'inAttesa': return StatoPietanza.inAttesa;
      case 'inPreparazione': return StatoPietanza.inPreparazione;
      case 'pronto': return StatoPietanza.pronto;
      case 'servito': return StatoPietanza.servito;
      default: return StatoPietanza.inAttesa;
    }
  }

  double _calcolaTotaleOrdine(List<Pietanza> pietanze) {
    return pietanze.fold(0.0, (total, pietanza) => total + pietanza.prezzo);
  }

  Future<String> _getCurrentStatoString(String ordineId) async {
    final doc = await _firestore.collection('ordini').doc(ordineId).get();
    return doc.exists ? doc.data()!['stato'] : 'inAttesa';
  }
}