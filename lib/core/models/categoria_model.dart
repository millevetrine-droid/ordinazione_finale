import 'pietanza_model.dart';

class Categoria {
  final String id;
  final String nome;
  final String? emoji; // ✅ CAMBIATO: da required a optional
  final String? imageUrl; // ✅ NUOVO: campo per foto
  final List<Pietanza> pietanze;
  final String? tipo; // compatibility: 'macrocategoria'|'sottocategoria'|null
  final String? idPadre; // compatibility for subcategories
  final int ordine;
  final String macrocategoriaId;

  Categoria({
    required this.id,
    required this.nome,
    this.emoji, // ✅ CAMBIATO: non più required
    this.imageUrl, // ✅ NUOVO
    required this.pietanze,
    this.tipo,
    this.idPadre,
    this.ordine = 0,
    required this.macrocategoriaId,
  });

  factory Categoria.fromMap(Map<String, dynamic> map) {
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

    final pietList = (map['pietanze'] as List? ?? []).map((p) {
      if (p is Map<String, dynamic>) return Pietanza.fromMap(p);
      return Pietanza.fromMap(Map<String, dynamic>.from(p as Map));
    }).toList();

    return Categoria(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      emoji: map['emoji'], // ✅ CAMBIATO: non più required
  imageUrl: parseImage(map), // ✅ NUOVO: accepts legacy keys
      tipo: map['tipo'] ?? map['type'],
      idPadre: map['idPadre'] ?? map['parentId'],
  ordine: parseOrdine(map['ordine'] ?? map['order']),
      macrocategoriaId: map['macrocategoriaId'] ?? map['macrocategoria'] ?? '',
      pietanze: pietList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'emoji': emoji, // ✅ CAMBIATO
      'imageUrl': imageUrl, // ✅ NUOVO
      'tipo': tipo,
      'idPadre': idPadre,
      'ordine': ordine,
      'macrocategoriaId': macrocategoriaId,
      'pietanze': pietanze.map((p) => p.toMap()).toList(),
    };
  }

  Categoria copyWith({
    String? id,
    String? nome,
    String? emoji,
    String? imageUrl, // ✅ NUOVO
    List<Pietanza>? pietanze,
    int? ordine,
    String? macrocategoriaId,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl, // ✅ NUOVO
      ordine: ordine ?? this.ordine,
      macrocategoriaId: macrocategoriaId ?? this.macrocategoriaId,
      pietanze: pietanze ?? this.pietanze,
    );
  }

  // ✅ NUOVO: Getter per visualizzare emoji o icona di default
  String get iconaVisualizzata => emoji ?? '📂';
  
  // ✅ NUOVO: Verifica se ha una foto
  bool get haFoto => imageUrl != null && imageUrl!.isNotEmpty;

  int get numeroPietanze => pietanze.length;

  List<Pietanza> get pietanzeDisponibili {
    return pietanze.where((p) => p.disponibile).toList();
  }

  bool get haPietanze => pietanze.isNotEmpty;

  bool get haPietanzeDisponibili => pietanzeDisponibili.isNotEmpty;

  List<String> get pietanzeIds {
    return pietanze.map((p) => p.id).toList();
  }

  // --- Compatibility helpers for legacy API/tests ---
  bool get isMacrocategoria => (tipo ?? 'macrocategoria') == 'macrocategoria';
  String? get immagine => imageUrl;
}