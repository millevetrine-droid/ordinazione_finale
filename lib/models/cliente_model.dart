import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String id;
  final String telefono;
  final String nome;
  final int punti;
  final DateTime dataRegistrazione;
  final DateTime? ultimoOrdine;
  final List<String> regaliInviatiIds;
  final List<String> regaliRicevutiIds;
  final String? email;
  final String? password;

  Cliente({
    required this.id,
    required this.telefono,
    required this.nome,
    required this.punti,
    required this.dataRegistrazione,
    this.ultimoOrdine,
    this.regaliInviatiIds = const [],
    this.regaliRicevutiIds = const [],
    this.email,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'telefono': telefono,
      'nome': nome,
      'punti': punti,
      'dataRegistrazione': Timestamp.fromDate(dataRegistrazione),
      'ultimoOrdine': ultimoOrdine != null ? Timestamp.fromDate(ultimoOrdine!) : null,
      'regaliInviatiIds': regaliInviatiIds,
      'regaliRicevutiIds': regaliRicevutiIds,
      'email': email,
      'password': password,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map, String id) {
    return Cliente(
      id: id,
      telefono: map['telefono'] ?? '',
      nome: map['nome'] ?? '',
      punti: map['punti'] ?? 0,
      dataRegistrazione: map['dataRegistrazione'] != null 
          ? (map['dataRegistrazione'] as Timestamp).toDate() 
          : DateTime.now(),
      ultimoOrdine: map['ultimoOrdine'] != null 
          ? (map['ultimoOrdine'] as Timestamp).toDate() 
          : null,
      regaliInviatiIds: List<String>.from(map['regaliInviatiIds'] ?? []),
      regaliRicevutiIds: List<String>.from(map['regaliRicevutiIds'] ?? []),
      email: map['email'],
      password: map['password'],
    );
  }

  // 👇 AGGIUNTO METODO FROM SNAPSHOT PER FACILITÀ
  factory Cliente.fromSnapshot(DocumentSnapshot snapshot) {
    return Cliente.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  Cliente copyWith({
    String? id,
    String? telefono,
    String? nome,
    int? punti,
    DateTime? dataRegistrazione,
    DateTime? ultimoOrdine,
    List<String>? regaliInviatiIds,
    List<String>? regaliRicevutiIds,
    String? email,
    String? password,
  }) {
    return Cliente(
      id: id ?? this.id,
      telefono: telefono ?? this.telefono,
      nome: nome ?? this.nome,
      punti: punti ?? this.punti,
      dataRegistrazione: dataRegistrazione ?? this.dataRegistrazione,
      ultimoOrdine: ultimoOrdine ?? this.ultimoOrdine,
      regaliInviatiIds: regaliInviatiIds ?? this.regaliInviatiIds,
      regaliRicevutiIds: regaliRicevutiIds ?? this.regaliRicevutiIds,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}