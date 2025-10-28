class PietanzaOrdine {
  final String idPietanza;
  final String nome;
  final double prezzo;
  final int quantita;
  final String stato;

  PietanzaOrdine({
    required this.idPietanza,
    required this.nome,
    required this.prezzo,
    required this.quantita,
    required this.stato,
  });

  factory PietanzaOrdine.fromMap(Map<String, dynamic> map) {
    return PietanzaOrdine(
      idPietanza: map['idPietanza'] ?? '',
      nome: map['nome'] ?? '',
      prezzo: (map['prezzo'] ?? 0).toDouble(),
      quantita: map['quantita'] ?? 0,
      stato: map['stato'] ?? 'in_attesa',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPietanza': idPietanza,
      'nome': nome,
      'prezzo': prezzo,
      'quantita': quantita,
      'stato': stato,
    };
  }
}