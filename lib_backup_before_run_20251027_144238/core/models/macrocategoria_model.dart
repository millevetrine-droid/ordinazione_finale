class Macrocategoria {
  final String id;
  final String nome;
  final String? emoji; // ✅ CAMBIATO: da required a optional
  final String? imageUrl; // ✅ NUOVO: campo per foto
  final int ordine;
  final List<String> categorieIds;

  Macrocategoria({
    required this.id,
    required this.nome,
    this.emoji, // ✅ CAMBIATO: non più required
    this.imageUrl, // ✅ NUOVO
    required this.ordine,
    this.categorieIds = const [],
  });

  Macrocategoria copyWith({
    String? id,
    String? nome,
    String? emoji,
    String? imageUrl, // ✅ NUOVO
    int? ordine,
    List<String>? categorieIds,
  }) {
    return Macrocategoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl, // ✅ NUOVO
      ordine: ordine ?? this.ordine,
      categorieIds: categorieIds ?? this.categorieIds,
    );
  }

  factory Macrocategoria.fromMap(Map<String, dynamic> map) {
    return Macrocategoria(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      emoji: map['emoji'], // ✅ CAMBIATO: non più required
      imageUrl: map['imageUrl'], // ✅ NUOVO
      ordine: map['ordine'] ?? 0,
      categorieIds: List<String>.from(map['categorieIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'emoji': emoji, // ✅ CAMBIATO
      'imageUrl': imageUrl, // ✅ NUOVO
      'ordine': ordine,
      'categorieIds': categorieIds,
    };
  }

  // ✅ NUOVO: Getter per visualizzare emoji o icona di default
  String get iconaVisualizzata => emoji ?? '📁';
  
  // ✅ NUOVO: Verifica se ha una foto
  bool get haFoto => imageUrl != null && imageUrl!.isNotEmpty;

  int get categorie => categorieIds.length;

  String get nomeCompleto => '$iconaVisualizzata $nome';

  bool get haCategorie => categorieIds.isNotEmpty;
}