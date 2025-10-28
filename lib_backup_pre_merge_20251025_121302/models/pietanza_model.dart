class Pietanza {
  final String id;
  final String nome;
  final double prezzo;
  final String categoria; // Mantenuto per compatibilità
  final String categoriaId; // Nuovo campo per relazione gerarchica
  final String descrizione;
  final String immagine;
  final int ordine;
  final bool usaFoto;
  final String? fotoUrl;
  final String? allergeni;

  Pietanza({
    required this.id,
    required this.nome,
    required this.prezzo,
    required this.categoria,
    required this.categoriaId,
    this.descrizione = '',
    required this.immagine,
    required this.ordine,
    this.usaFoto = false,
    this.fotoUrl,
    this.allergeni,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'prezzo': prezzo,
      'categoria': categoria,
      'categoriaId': categoriaId,
      'descrizione': descrizione,
      'immagine': immagine,
      'ordine': ordine,
      'usaFoto': usaFoto,
      'fotoUrl': fotoUrl,
      'allergeni': allergeni,
    };
  }

  static Pietanza fromMap(Map<String, dynamic> map) {
    return Pietanza(
      id: map['id'],
      nome: map['nome'],
      prezzo: (map['prezzo'] as num).toDouble(),
      categoria: map['categoria'] ?? '',
      categoriaId: map['categoriaId'] ?? map['categoria'] ?? '',
      descrizione: map['descrizione'] ?? '',
      immagine: map['immagine'],
      ordine: map['ordine'],
      usaFoto: map['usaFoto'] ?? false,
      fotoUrl: map['fotoUrl'],
      allergeni: map['allergeni'],
    );
  }

  Pietanza copyWith({
    String? id,
    String? nome,
    double? prezzo,
    String? categoria,
    String? categoriaId,
    String? descrizione,
    String? immagine,
    int? ordine,
    bool? usaFoto,
    String? fotoUrl,
    String? allergeni,
  }) {
    return Pietanza(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      prezzo: prezzo ?? this.prezzo,
      categoria: categoria ?? this.categoria,
      categoriaId: categoriaId ?? this.categoriaId,
      descrizione: descrizione ?? this.descrizione,
      immagine: immagine ?? this.immagine,
      ordine: ordine ?? this.ordine,
      usaFoto: usaFoto ?? this.usaFoto,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      allergeni: allergeni ?? this.allergeni,
    );
  }
}