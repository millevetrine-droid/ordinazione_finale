import 'package:cloud_firestore/cloud_firestore.dart';

class Ordine {
  final String id;
  final String tavolo;
  final List<PietanzaOrdine> pietanze;
  final DateTime timestamp;
  final int numeroPersone;
  final String? telefonoCliente;
  final String? nomeCliente;
  final bool accumulaPunti;
  final String statoComplessivo;
  final double totale;

  Ordine({
    required this.id,
    required this.tavolo,
    required this.pietanze,
    required this.timestamp,
    required this.numeroPersone,
    this.telefonoCliente,
    this.nomeCliente,
    required this.accumulaPunti,
    required this.statoComplessivo,
    required this.totale,
  });

  factory Ordine.fromFirestore(String id, Map<String, dynamic> data) {
    final timestamp = data['timestamp'] as Timestamp;
    final pietanzeData = data['pietanze'] as List;
    
    final pietanze = pietanzeData.map((p) {
      return PietanzaOrdine.fromMap(Map<String, dynamic>.from(p));
    }).toList();

    final totale = pietanze.fold(0.0, (acc, pietanza) {
      return acc + (pietanza.prezzo * pietanza.quantita);
    });

    return Ordine(
      id: id,
      tavolo: data['tavolo'] ?? 'N/A',
      pietanze: pietanze,
      timestamp: timestamp.toDate(),
      numeroPersone: data['numeroPersone'] ?? 1,
      telefonoCliente: data['telefonoCliente'],
      nomeCliente: data['nomeCliente'],
      accumulaPunti: data['accumulaPunti'] ?? false,
      statoComplessivo: data['statoComplessivo'] ?? 'in_attesa',
      totale: totale,
    );
  }
}

class PietanzaOrdine {
  final String idPietanza;
  final String nome;
  final double prezzo;
  final int quantita;
  final String stato;

  PietanzaOrdine({
    required this.idPietanza,
    required this.nome,
    required this.prezzo,
    required this.quantita,
    required this.stato,
  });

  Map<String, dynamic> toMap() {
    return {
      'idPietanza': idPietanza,
      'nome': nome,
      'prezzo': prezzo,
      'quantita': quantita,
      'stato': stato,
    };
  }

  static PietanzaOrdine fromMap(Map<String, dynamic> map) {
    return PietanzaOrdine(
      idPietanza: map['idPietanza'],
      nome: map['nome'],
      prezzo: (map['prezzo'] as num).toDouble(),
      quantita: map['quantita'],
      stato: map['stato'],
    );
  }
}

class Transazione {
  final String id;
  final String tavolo;
  final double importo;
  final String metodoPagamento;
  final List<Map<String, dynamic>> pietanze;
  final String? note;
  final DateTime data;

  Transazione({
    required this.id,
    required this.tavolo,
    required this.importo,
    required this.metodoPagamento,
    required this.pietanze,
    this.note,
    required this.data,
  });

  factory Transazione.fromFirestore(String id, Map<String, dynamic> data) {
    final timestamp = data['data'] as Timestamp;
    
    return Transazione(
      id: id,
      tavolo: data['tavolo'] ?? 'N/A',
      importo: (data['importo'] as num).toDouble(),
      metodoPagamento: data['metodoPagamento'] ?? 'contanti',
      pietanze: List<Map<String, dynamic>>.from(data['pietanze'] ?? []),
      note: data['note'],
      data: timestamp.toDate(),
    );
  }
}