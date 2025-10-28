class SessioneTavolo {
  final String id;
  final int numeroTavolo;
  final String codiceSessione;
  final DateTime dataCreazione;
  final DateTime dataScadenza;
  final String idCameriere;
  final bool attiva;
  final String? idCliente;

  SessioneTavolo({
    required this.id,
    required this.numeroTavolo,
    required this.codiceSessione,
    required this.dataCreazione,
    required this.dataScadenza,
    required this.idCameriere,
    this.attiva = true,
    this.idCliente,
  });

  bool get isScaduta => DateTime.now().isAfter(dataScadenza);
  bool get isValida => attiva && !isScaduta;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroTavolo': numeroTavolo,
      'codiceSessione': codiceSessione,
      'dataCreazione': dataCreazione.toIso8601String(),
      'dataScadenza': dataScadenza.toIso8601String(),
      'idCameriere': idCameriere,
      'attiva': attiva,
      'idCliente': idCliente,
    };
  }

  factory SessioneTavolo.fromMap(Map<String, dynamic> map) {
    return SessioneTavolo(
      id: map['id'],
      numeroTavolo: map['numeroTavolo'],
      codiceSessione: map['codiceSessione'],
      dataCreazione: DateTime.parse(map['dataCreazione']),
      dataScadenza: DateTime.parse(map['dataScadenza']),
      idCameriere: map['idCameriere'],
      attiva: map['attiva'],
      idCliente: map['idCliente'],
    );
  }
}