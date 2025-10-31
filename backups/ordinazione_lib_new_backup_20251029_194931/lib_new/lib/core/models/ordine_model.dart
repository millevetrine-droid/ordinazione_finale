import 'pietanza_model.dart';
// Firestore Timestamp used when mapping from/to Firestore documents
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

enum StatoOrdine {
  inAttesa,
  inPreparazione,
  pronto,
  servito,
  completato,
}

// ✅ NUOVO MODELLO: StatoChange per tracking
class StatoChange {
  final StatoOrdine fromStato;
  final StatoOrdine toStato;
  final DateTime timestamp;
  final String user;

  StatoChange({
    required this.fromStato,
    required this.toStato,
    required this.timestamp,
    required this.user,
  });
}

class Ordine {
  final String id;
  final String numeroTavolo;
  final List<Pietanza> pietanze;
  final StatoOrdine stato;
  final DateTime timestamp;
  final String idCameriere;
  final String note;
  final List<StatoChange> storicoStati; // ✅ NUOVO: storico stati

  Ordine({
    required this.id,
    required this.numeroTavolo,
    required this.pietanze,
    required this.stato,
    required this.timestamp,
    required this.idCameriere,
    this.note = '',
    this.storicoStati = const [], // ✅ NUOVO: storico iniziale vuoto
  });

  // ✅ GETTER PER TOTALE (ESISTENTE)
  double get totale {
    return pietanze.fold(0.0, (total, pietanza) => total + pietanza.prezzo);
  }

  // ✅ NUOVO METODO: verifica se può recuperare da stato
  bool canRecuperareFromStato(StatoOrdine nuovoStato, String ruolo) {
    if (ruolo == 'admin') {
      return nuovoStato == StatoOrdine.inPreparazione || 
             nuovoStato == StatoOrdine.pronto;
    }
    if (ruolo == 'cuoco') {
      return stato == StatoOrdine.pronto && nuovoStato == StatoOrdine.inPreparazione;
    }
    if (ruolo == 'cameriere') {
      return stato == StatoOrdine.servito && nuovoStato == StatoOrdine.pronto;
    }
    return false;
  }

  // ✅ COPYWITH AGGIORNATO CON STORICO
  Ordine copyWith({
    String? id,
    String? numeroTavolo,
    List<Pietanza>? pietanze,
    StatoOrdine? stato,
    DateTime? timestamp,
    String? idCameriere,
    String? note,
    List<StatoChange>? storicoStati, // ✅ NUOVO: storico in copyWith
  }) {
    return Ordine(
      id: id ?? this.id,
      numeroTavolo: numeroTavolo ?? this.numeroTavolo,
      pietanze: pietanze ?? this.pietanze,
      stato: stato ?? this.stato,
      timestamp: timestamp ?? this.timestamp,
      idCameriere: idCameriere ?? this.idCameriere,
      note: note ?? this.note,
      storicoStati: storicoStati ?? this.storicoStati, // ✅ NUOVO
    );
  }

  // ✅ FACTORY AGGIORNATO CON STORICO
  factory Ordine.fromMap(Map<String, dynamic> map) {
    // compatibility: accept legacy field names and multiple timestamp/enum formats
    dynamic rawTimestamp = map['timestamp'] ?? map['data'] ?? map['time'];
    DateTime parsedTimestamp;
    if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    } else if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else if (rawTimestamp is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else {
      parsedTimestamp = DateTime.now();
    }

    // stato: accept int (index) or string name
    dynamic rawStato = map['stato'] ?? map['statoComplessivo'] ?? 0;
    StatoOrdine parsedStato;
    if (rawStato is int) {
      parsedStato = StatoOrdine.values[(rawStato < StatoOrdine.values.length) ? rawStato : 0];
    } else if (rawStato is String) {
      parsedStato = StatoOrdine.values.firstWhere(
        (e) => e.toString().split('.').last == rawStato || e.toString() == rawStato,
        orElse: () => StatoOrdine.inAttesa,
      );
    } else {
      parsedStato = StatoOrdine.inAttesa;
    }

    final pietanzeList = (map['pietanze'] as List? ?? []).map((p) => Pietanza.fromMap(Map<String, dynamic>.from(p))).toList();

    final storico = (map['storicoStati'] as List? ?? []).map((s) {
      final fromRaw = s['fromStato'];
      final toRaw = s['toStato'];
      StatoOrdine from = (fromRaw is int) ? StatoOrdine.values[fromRaw] : (fromRaw is String ? StatoOrdine.values.firstWhere((e)=>e.toString().split('.').last==fromRaw, orElse: ()=>StatoOrdine.inAttesa) : StatoOrdine.inAttesa);
      StatoOrdine to = (toRaw is int) ? StatoOrdine.values[toRaw] : (toRaw is String ? StatoOrdine.values.firstWhere((e)=>e.toString().split('.').last==toRaw, orElse: ()=>StatoOrdine.inAttesa) : StatoOrdine.inAttesa);
      // parse timestamp in same tolerant way
      dynamic sTs = s['timestamp'];
      DateTime sParsed;
      if (sTs is Timestamp) {
        sParsed = sTs.toDate();
      } else if (sTs is String) sParsed = DateTime.tryParse(sTs) ?? DateTime.now(); else if (sTs is int) sParsed = DateTime.fromMillisecondsSinceEpoch(sTs); else if (sTs is DateTime) sParsed = sTs; else sParsed = DateTime.now();
      return StatoChange(fromStato: from, toStato: to, timestamp: sParsed, user: s['user'] ?? '');
    }).toList();

    return Ordine(
      id: map['id'] ?? '',
      numeroTavolo: map['numeroTavolo'] ?? map['tavolo'] ?? '',
      pietanze: pietanzeList,
      stato: parsedStato,
      timestamp: parsedTimestamp,
      idCameriere: map['idCameriere'] ?? map['cameriereId'] ?? '',
      note: map['note'] ?? '',
      storicoStati: storico,
    );
  }

  // ✅ TOMAP AGGIORNATO CON STORICO
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroTavolo': numeroTavolo,
      'pietanze': pietanze.map((p) => p.toMap()).toList(),
      'stato': stato.index,
      'timestamp': timestamp.toIso8601String(),
      'idCameriere': idCameriere,
      'note': note,
      'storicoStati': storicoStati.map((s) => ({
        'fromStato': s.fromStato.index,
        'toStato': s.toStato.index,
        'timestamp': s.timestamp.toIso8601String(),
        'user': s.user,
      })).toList(), // ✅ NUOVO: serializzazione storico
    };
  }
}