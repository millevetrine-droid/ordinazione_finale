import 'pietanza_model.dart';

class Categoria {
  final String id;
  final String nome;
  final String? emoji; // ✅ CAMBIATO: da required a optional
  final String? imageUrl; // ✅ NUOVO: campo per foto
  final List<Pietanza> pietanze;
  final int ordine;
  final String macrocategoriaId;

  Categoria({
    required this.id,
    required this.nome,
    this.emoji, // ✅ CAMBIATO: non più required
    this.imageUrl, // ✅ NUOVO
    required this.pietanze,
    this.ordine = 0,
    required this.macrocategoriaId,
  });

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
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
}