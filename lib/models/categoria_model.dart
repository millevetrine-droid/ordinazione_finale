class Categoria {
  final String id;
  final String nome;
  final int ordine;
  final String? immagine;
  final String tipo; // 'macrocategoria' o 'sottocategoria'
  final String? idPadre; // Solo per sottocategorie

  Categoria({
    required this.id,
    required this.nome,
    required this.ordine,
    this.immagine,
    required this.tipo,
    this.idPadre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ordine': ordine,
      'immagine': immagine,
      'tipo': tipo,
      'idPadre': idPadre,
    };
  }

  static Categoria fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nome: map['nome'],
      ordine: map['ordine'],
      immagine: map['immagine'],
      tipo: map['tipo'] ?? 'macrocategoria',
      idPadre: map['idPadre'],
    );
  }

  Categoria copyWith({
    String? id,
    String? nome,
    int? ordine,
    String? immagine,
    String? tipo,
    String? idPadre,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      ordine: ordine ?? this.ordine,
      immagine: immagine ?? this.immagine,
      tipo: tipo ?? this.tipo,
      idPadre: idPadre ?? this.idPadre,
    );
  }

  bool get isMacrocategoria => tipo == 'macrocategoria';
  bool get isSottocategoria => tipo == 'sottocategoria';
}