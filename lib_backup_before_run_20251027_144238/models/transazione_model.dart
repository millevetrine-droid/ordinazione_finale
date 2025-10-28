import 'package:cloud_firestore/cloud_firestore.dart';
class Transazione {
  final String id;
  final String tavolo;
  final double importo;
  final String metodoPagamento;
  final DateTime data;
  final String? note;
  final List<Map<String, dynamic>> pietanze;

  Transazione({
    required this.id,
    required this.tavolo,
    required this.importo,
    required this.metodoPagamento,
    required this.data,
    this.note,
    required this.pietanze,
  });

  factory Transazione.fromFirestore(String id, Map<String, dynamic> data) {
    return Transazione(
      id: id,
      tavolo: data['tavolo'] ?? '',
      importo: (data['importo'] ?? 0).toDouble(),
      metodoPagamento: data['metodo_pagamento'] ?? 'contanti',
      data: (data['data'] as Timestamp).toDate(),
      note: data['note'],
      pietanze: List<Map<String, dynamic>>.from(data['pietanze'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tavolo': tavolo,
      'importo': importo,
      'metodo_pagamento': metodoPagamento,
      'data': Timestamp.fromDate(data),
      'note': note,
      'pietanze': pietanze,
    };
  }
}