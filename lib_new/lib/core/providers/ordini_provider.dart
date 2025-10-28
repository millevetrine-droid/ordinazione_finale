/// FILE: [lib/core/providers/ordini_provider.dart]
/// SCOPO: [Gestione ordini con persistenza Firestore e sincronizzazione tempo reale]
/// RELAZIONI: 
///   - Importa: [dart:async, flutter/foundation.dart, models, services/firebase_service]
///   - Collegato a: [ordini_service.dart per persistenza, varie schermate ordini]
///   - Dipendenze: [OrdiniService, FirebaseService, StreamSubscription]
/// FUNZIONALITÀ: [Gestione ordini con sync Firestore, stati tempo reale, statistiche]
/// MODIFICHE: [Aggiunto import dart:async, mantenute tutte le funzionalità esistenti]
/// DA VERIFICARE: [Stream Firestore, salvataggio ordini, aggiornamenti stati]
library;

import 'dart:async'; // ✅ AGGIUNTO PER StreamSubscription
import 'package:flutter/foundation.dart';
import 'package:ordinazione/core/models/ordine_model.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'package:ordinazione/core/services/firebase_service.dart';

class OrdiniProvider with ChangeNotifier {
  final List<Ordine> _ordiniLocali = []; // Backup per offline
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _ordiniSubscription;

  List<Ordine> get ordini => List.from(_ordiniLocali);
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrdiniProvider() {
    _initializeFirestoreListener();
  }

  @override
  void dispose() {
    _ordiniSubscription?.cancel();
    super.dispose();
  }

  // ✅ INIZIALIZZAZIONE STREAM FIRESTORE
  void _initializeFirestoreListener() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ordiniSubscription = FirebaseService().ordini.getOrdiniStream().listen(
        (ordini) {
          _ordiniLocali.clear();
          _ordiniLocali.addAll(ordini);
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Errore sincronizzazione ordini: $error';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Errore inizializzazione listener: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ METODI PER STATISTICHE (ESISTENTI - COMPATIBILI)
  int get totaleOrdiniOggi {
    final oggi = DateTime.now();
    return _ordiniLocali.where((ordine) => 
      ordine.timestamp.year == oggi.year &&
      ordine.timestamp.month == oggi.month &&
      ordine.timestamp.day == oggi.day
    ).length;
  }

  double get incassoOggi {
    final oggi = DateTime.now();
    final ordiniOggi = _ordiniLocali.where((ordine) => 
      ordine.timestamp.year == oggi.year &&
      ordine.timestamp.month == oggi.month &&
      ordine.timestamp.day == oggi.day
    );
    
    return ordiniOggi.fold(0.0, (total, ordine) => total + _calcolaTotaleOrdine(ordine));
  }

  List<Ordine> get ordiniAttivi {
    return _ordiniLocali.where((ordine) => 
      ordine.stato != StatoOrdine.completato
    ).toList();
  }

  List<Ordine> get archivioOrdini {
    return _ordiniLocali.where((ordine) => 
      ordine.stato == StatoOrdine.completato
    ).toList();
  }

  // ✅ NUOVO: AGGIUNTA ORDINE CON PERSISTENZA FIRESTORE
  Future<void> aggiungiOrdine(Ordine ordine) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Salva su Firestore
      await FirebaseService().ordini.salvaOrdine(ordine);
      
      // Aggiungi localmente (lo stream si aggiornerà automaticamente)
      _ordiniLocali.add(ordine);
      
      _isLoading = false;
      notifyListeners();
      
  debugPrint('✅ Ordine ${ordine.id} aggiunto e salvato su Firestore');
    } catch (e) {
      _error = 'Errore aggiunta ordine: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ✅ AGGIORNATO: AGGIORNA STATO ORDINE CON FIRESTORE
  Future<void> aggiornaStatoOrdine(String ordineId, StatoOrdine nuovoStato, String user) async {
    try {
      // Ottimistica: aggiorna lo stato localmente prima della chiamata remota
      final index = _ordiniLocali.indexWhere((o) => o.id == ordineId);
      Ordine? oldOrdine;
      if (index != -1) {
        oldOrdine = _ordiniLocali[index];
        final updated = oldOrdine.copyWith(stato: nuovoStato, storicoStati: [
          ...oldOrdine.storicoStati,
          StatoChange(fromStato: oldOrdine.stato, toStato: nuovoStato, timestamp: DateTime.now(), user: user),
        ]);
        _ordiniLocali[index] = updated;
        notifyListeners();
      }

      await FirebaseService().ordini.aggiornaStatoOrdine(ordineId, nuovoStato, user);
      // Lo stream Firestore dovrebbe allineare lo stato finale
      debugPrint('✅ Stato ordine $ordineId aggiornato a: $nuovoStato');
    } catch (e) {
      _error = 'Errore aggiornamento stato ordine: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ✅ AGGIORNATO: AGGIORNA STATO PIETANZA CON FIRESTORE
  Future<void> aggiornaStatoPietanza({
    required String ordineId,
    required String pietanzaId,
    required StatoPietanza nuovoStato,
    required String user,
  }) async {
    try {
      // Ottimistica: aggiorna lo stato della pietanza localmente
      final ordineIndex = _ordiniLocali.indexWhere((o) => o.id == ordineId);
      Pietanza? oldPietanza;
      if (ordineIndex != -1) {
        final ordine = _ordiniLocali[ordineIndex];
        final pietIndex = ordine.pietanze.indexWhere((p) => p.id == pietanzaId);
        if (pietIndex != -1) {
          oldPietanza = ordine.pietanze[pietIndex];
          final updatedPietanza = oldPietanza.copyWith(stato: nuovoStato);
          final updatedPietanze = List<Pietanza>.from(ordine.pietanze);
          updatedPietanze[pietIndex] = updatedPietanza;
          _ordiniLocali[ordineIndex] = ordine.copyWith(pietanze: updatedPietanze);
          notifyListeners();
        }
      }

      await FirebaseService().ordini.aggiornaStatoPietanza(
        ordineId: ordineId,
        pietanzaId: pietanzaId,
        nuovoStato: nuovoStato,
        user: user,
      );
      debugPrint('✅ Stato pietanza $pietanzaId aggiornato a: $nuovoStato');
    } catch (e) {
      _error = 'Errore aggiornamento stato pietanza: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ✅ METODI PER RECUPERO ORDINI (ESISTENTI - COMPATIBILI)
  List<Ordine> getOrdiniCucinaForCameriere() {
    return _ordiniLocali.where((ordine) => 
      ordine.stato == StatoOrdine.inAttesa || 
      ordine.stato == StatoOrdine.inPreparazione
    ).toList();
  }

  List<Ordine> getOrdiniRecuperabiliCuoco() {
    return _ordiniLocali.where((ordine) => 
      ordine.pietanze.any((pietanza) => pietanza.isPronto) &&
      ordine.stato != StatoOrdine.completato
    ).toList();
  }

  List<Ordine> getOrdiniRecuperabiliCameriere() {
    return _ordiniLocali.where((ordine) => 
      ordine.pietanze.any((pietanza) => pietanza.isServito)
    ).toList();
  }

  // ✅ METODO PER CHECKOUT - NUOVO
  Future<void> checkout(Ordine ordine) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Salva l'ordine su Firestore
      await FirebaseService().ordini.salvaOrdine(ordine);
      
      // Lo stream si aggiornerà automaticamente con il nuovo ordine
      
      _isLoading = false;
      notifyListeners();
      
  debugPrint('✅ CHECKOUT COMPLETATO - Ordine ${ordine.id} salvato su Firestore');
    } catch (e) {
      _error = 'Errore durante il checkout: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ✅ METODI ESISTENTI (COMPATIBILITÀ)
  void recuperaOrdine(String ordineId, StatoOrdine nuovoStato, String user) {
    aggiornaStatoOrdine(ordineId, nuovoStato, user);
  }

  void rimuoviOrdine(String ordineId) {
    FirebaseService().ordini.eliminaOrdine(ordineId);
    // Lo stream si aggiornerà automaticamente
  }

  // ✅ RESET DATABASE (SOLO LOCALE - PER TEST)
  void resetDatabase() {
    _ordiniLocali.clear();
    notifyListeners();
  }

  // ===========================================================================
  // ✅ METODI ESISTENTI - INVARIATI (compatibilità)
  // ===========================================================================

  double _calcolaTotaleOrdine(Ordine ordine) {
    return ordine.pietanze.fold(0.0, (total, pietanza) => total + pietanza.prezzo);
  }

  // Helper removed: not used currently

  List<Pietanza> getPietanzeByStato(String ordineId, StatoPietanza stato) {
    final ordine = _ordiniLocali.firstWhere((ordine) => ordine.id == ordineId, orElse: () => throw Exception('Ordine non trovato'));
    return ordine.pietanze.where((pietanza) => pietanza.stato == stato).toList();
  }

  void segnaPietanzaPronta(String ordineId, String pietanzaId, String user) {
    aggiornaStatoPietanza(
      ordineId: ordineId,
      pietanzaId: pietanzaId,
      nuovoStato: StatoPietanza.pronto,
      user: user,
    );
  }

  void iniziaPreparazionePietanza(String ordineId, String pietanzaId, String user) {
    aggiornaStatoPietanza(
      ordineId: ordineId,
      pietanzaId: pietanzaId,
      nuovoStato: StatoPietanza.inPreparazione,
      user: user,
    );
  }

  void recuperaPietanza(String ordineId, String pietanzaId, String user) {
    aggiornaStatoPietanza(
      ordineId: ordineId,
      pietanzaId: pietanzaId,
      nuovoStato: StatoPietanza.pronto,
      user: user,
    );
  }

  bool sonoTuttePietanzePronte(String ordineId) {
    final ordine = _ordiniLocali.firstWhere((ordine) => ordine.id == ordineId, orElse: () => throw Exception('Ordine non trovato'));
    return ordine.pietanze.every((pietanza) => pietanza.isPronto);
  }

  Map<StatoPietanza, int> contaPietanzePerStato(String ordineId) {
    final ordine = _ordiniLocali.firstWhere((ordine) => ordine.id == ordineId, orElse: () => throw Exception('Ordine non trovato'));
    
    final conteggio = <StatoPietanza, int>{};
    for (final stato in StatoPietanza.values) {
      conteggio[stato] = ordine.pietanze.where((p) => p.stato == stato).length;
    }
    
    return conteggio;
  }

  List<Ordine> getOrdiniConPietanzeInPreparazione() {
    return _ordiniLocali.where((ordine) =>
      ordine.pietanze.any((pietanza) => pietanza.isInPreparazione) &&
      ordine.stato != StatoOrdine.completato
    ).toList();
  }

  List<Ordine> getOrdiniConPietanzePronte() {
    return _ordiniLocali.where((ordine) =>
      ordine.pietanze.any((pietanza) => pietanza.isPronto) &&
      ordine.stato != StatoOrdine.completato
    ).toList();
  }

  List<Map<String, dynamic>> getPietanzePronteDaServire() {
    final result = <Map<String, dynamic>>[];
    
    for (final ordine in _ordiniLocali) {
      for (final pietanza in ordine.pietanze) {
        if (pietanza.stato == StatoPietanza.pronto) {
          result.add({
            'ordine': ordine,
            'pietanza': pietanza,
            'tavolo': ordine.numeroTavolo,
            'timestampOrdine': ordine.timestamp,
          });
        }
      }
    }
    
    result.sort((a, b) => (a['timestampOrdine'] as DateTime)
        .compareTo(b['timestampOrdine'] as DateTime));
    
    return result;
  }

  void segnaPietanzaServita({
    required String ordineId,
    required String pietanzaId,
    required String user,
  }) {
    aggiornaStatoPietanza(
      ordineId: ordineId,
      pietanzaId: pietanzaId,
      nuovoStato: StatoPietanza.servito,
      user: user,
    );
  }

  bool ordineHaPietanzePronte(String ordineId) {
    final ordine = _ordiniLocali.firstWhere(
      (ordine) => ordine.id == ordineId,
      orElse: () => throw Exception('Ordine non trovato'),
    );
    return ordine.pietanze.any((pietanza) => pietanza.isPronto);
  }

  int contaPietanzeProntePerOrdine(String ordineId) {
    final ordine = _ordiniLocali.firstWhere(
      (ordine) => ordine.id == ordineId,
      orElse: () => throw Exception('Ordine non trovato'),
    );
    return ordine.pietanze.where((pietanza) => pietanza.isPronto).length;
  }

  List<Pietanza> getPietanzeProntePerOrdine(String ordineId) {
    final ordine = _ordiniLocali.firstWhere(
      (ordine) => ordine.id == ordineId,
      orElse: () => throw Exception('Ordine non trovato'),
    );
    return ordine.pietanze.where((pietanza) => pietanza.isPronto).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}