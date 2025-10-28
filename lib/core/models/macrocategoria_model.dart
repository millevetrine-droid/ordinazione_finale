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
    int parseOrdine(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String? parseImage(Map<String, dynamic> m) {
      if (m['imageUrl'] != null) return m['imageUrl'] as String?;
      if (m['immagine'] != null) return m['immagine'] as String?;
      if (m['fotoUrl'] != null) return m['fotoUrl'] as String?;
      if (m['foto'] != null) return m['foto'] as String?;
      return null;
    }

    List<String> parseCategorieIds(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      if (v is String) return v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      return [];
    }

    return Macrocategoria(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      emoji: map['emoji'],
      imageUrl: parseImage(map),
      ordine: parseOrdine(map['ordine'] ?? map['order']),
      categorieIds: parseCategorieIds(map['categorieIds'] ?? map['categorie'] ?? []),
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