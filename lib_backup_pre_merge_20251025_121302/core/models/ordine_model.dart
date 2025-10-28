import 'pietanza_model.dart';

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
    return Ordine(
      id: map['id'] ?? '',
      numeroTavolo: map['numeroTavolo'] ?? '',
      pietanze: (map['pietanze'] as List).map((p) => Pietanza.fromMap(p)).toList(),
      stato: StatoOrdine.values[map['stato'] ?? 0],
      timestamp: DateTime.parse(map['timestamp']),
      idCameriere: map['idCameriere'] ?? '',
      note: map['note'] ?? '',
      storicoStati: (map['storicoStati'] as List? ?? []).map((s) => StatoChange(
        fromStato: StatoOrdine.values[s['fromStato']],
        toStato: StatoOrdine.values[s['toStato']],
        timestamp: DateTime.parse(s['timestamp']),
        user: s['user'],
      )).toList(), // ✅ NUOVO: deserializzazione storico
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