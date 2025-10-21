import 'package:cloud_firestore/cloud_firestore.dart';

// Simple data model for a menu category
class Categoria {
  final String id;
  final String nome;

  Categoria({required this.id, required this.nome});

  factory Categoria.fromMap(Map<String, dynamic> map, String id) =>
      Categoria(id: id, nome: map['nome'] as String? ?? '');

  Map<String, dynamic> toMap() => {'nome': nome};
}

class MenuRepository {
  // Minimal in-memory implementation. Replace with Firestore/HTTP later.
  MenuRepository();

  Future<List<Categoria>> fetchMacrocategorie() async {
    // simulate latency
    await Future.delayed(const Duration(milliseconds: 50));
    return [
      Categoria(id: '1', nome: 'Antipasti'),
      Categoria(id: '2', nome: 'Primi'),
      Categoria(id: '3', nome: 'Secondi'),
    ];
  }
}

/// Firestore-backed implementation. If Firestore isn't configured or an error
/// occurs, callers can catch and fallback to `MenuRepository`.
class MenuRepositoryFirestore extends MenuRepository {
  final FirebaseFirestore _firestore;

  MenuRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Categoria>> fetchMacrocategorie() async {
    final snapshot = await _firestore.collection('macrocategorie').get();
    return snapshot.docs
        .map((d) => Categoria.fromMap(d.data(), d.id))
        .toList(growable: false);
  }
}
