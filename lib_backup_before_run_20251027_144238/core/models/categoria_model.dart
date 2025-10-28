import 'pietanza_model.dart';

class Categoria {
  final String id;
  final String nome;
  final String? tipo;
  final String? idPadre;
  final String? emoji; // ✅ CAMBIATO: da required a optional
  final String? imageUrl; // ✅ NUOVO: campo per foto
  final List<Pietanza> pietanze;
  final int ordine;
  final String macrocategoriaId;

  Categoria({
    required this.id,
    required this.nome,
    this.tipo,
    this.idPadre,
    String? emoji,
    String? imageUrl,
    // Compat: legacy parameter name (immagine può essere emoji o url)
    String? immagine,
    List<Pietanza>? pietanze,
    this.ordine = 0,
    String? macrocategoriaId,
  }) :
        pietanze = pietanze ?? const [],
        macrocategoriaId = macrocategoriaId ?? '',
        emoji = emoji ?? immagine,
        imageUrl = imageUrl ?? ((immagine != null && immagine.startsWith('http')) ? immagine : imageUrl);

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      tipo: map['tipo'],
      idPadre: map['idPadre'],
      emoji: map['emoji'], // ✅ CAMBIATO: non più required
      imageUrl: map['imageUrl'], // ✅ NUOVO
      ordine: map['ordine'] ?? 0,
      macrocategoriaId: map['macrocategoriaId'] ?? '',
      pietanze: (map['pietanze'] as List? ?? []).map((p) => Pietanza.fromMap(p)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'idPadre': idPadre,
      'emoji': emoji, // ✅ CAMBIATO
      'imageUrl': imageUrl, // ✅ NUOVO
      'ordine': ordine,
      'macrocategoriaId': macrocategoriaId,
      'pietanze': pietanze.map((p) => p.toMap()).toList(),
    };
  }

  Categoria copyWith({
    String? id,
    String? nome,
    String? tipo,
    String? idPadre,
    String? emoji,
    String? imageUrl, // ✅ NUOVO
    List<Pietanza>? pietanze,
    int? ordine,
    String? macrocategoriaId,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      idPadre: idPadre ?? this.idPadre,
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

  // === BACKWARD-COMPATIBILITY ===
  /// Compat getter used by legacy code
  String get immagine => emoji ?? (imageUrl ?? '');

  /// Compat: determines if this category is a macrocategoria
  bool get isMacrocategoria => tipo == 'macrocategoria' || (idPadre == null || idPadre!.isEmpty);
}