import 'package:cloud_firestore/cloud_firestore.dart';

class RegaloPunti {
  final String id;
  final String daTelefono;
  final String aTelefono;
  final String daNome;
  final String aNome;
  final int punti;
  final DateTime data;
  final String? messaggio;
  final String stato; // 'completato', 'fallito', 'in_sospeso'

  RegaloPunti({
    required this.id,
    required this.daTelefono,
    required this.aTelefono,
    required this.daNome,
    required this.aNome,
    required this.punti,
    required this.data,
    this.messaggio,
    this.stato = 'completato',
  });

  Map<String, dynamic> toMap() {
    return {
      'daTelefono': daTelefono,
      'aTelefono': aTelefono,
      'daNome': daNome,
      'aNome': aNome,
      'punti': punti,
      'data': Timestamp.fromDate(data),
      'messaggio': messaggio,
      'stato': stato,
    };
  }

  factory RegaloPunti.fromMap(Map<String, dynamic> map) {
    return RegaloPunti(
      id: map['id'] ?? '', // 👈 CORRETTO: solo 1 parametro
      daTelefono: map['daTelefono'] ?? '',
      aTelefono: map['aTelefono'] ?? '',
      daNome: map['daNome'] ?? '',
      aNome: map['aNome'] ?? '',
      punti: map['punti'] ?? 0,
      data: (map['data'] as Timestamp).toDate(),
      messaggio: map['messaggio'],
      stato: map['stato'] ?? 'completato',
    );
  }
}
