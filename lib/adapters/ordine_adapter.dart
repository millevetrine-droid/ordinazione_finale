import 'package:ordinazione/core/models/ordine_model.dart';
import 'package:ordinazione/core/models/pietanza_model.dart' show Pietanza;

class OrdineAdapter {
  /// Convert a Map coming from the lib_new schema into the core Ordine model.
  static Ordine fromNewMap(String id, Map<String, dynamic> data) {
    final tavolo = (data['tavolo'] ?? 'N/A') as String;

    final pietanzeRaw = data['pietanze'] as List? ?? const [];
    final pietanze = pietanzeRaw.map((p) {
      final map = Map<String, dynamic>.from(p as Map);
      // Use core Pietanza.fromMap; if fields are missing, Pietanza.fromMap handles defaults.
      return Pietanza.fromMap(map);
    }).toList();

    final timestampRaw = data['timestamp'];
    final DateTime timestamp;
    if (timestampRaw is DateTime) {
      timestamp = timestampRaw;
    } else if (timestampRaw is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(timestampRaw);
    } else if (timestampRaw is String) {
      timestamp = DateTime.tryParse(timestampRaw) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }

    // Map string status to enum if possible
    final statoStr = (data['statoComplessivo'] ?? 'in_attesa') as String;
    StatoOrdine stato = StatoOrdine.inAttesa;
    if (statoStr.contains('prepar')) stato = StatoOrdine.inPreparazione;
    if (statoStr.contains('pronto')) stato = StatoOrdine.pronto;
    if (statoStr.contains('servito')) stato = StatoOrdine.servito;
    if (statoStr.contains('complet')) stato = StatoOrdine.completato;

    final idCameriere = (data['idCameriere'] ?? '') as String;
    final noteParts = <String>[];
    if (data['telefonoCliente'] != null) noteParts.add('tel:${data['telefonoCliente']}');
    if (data['nomeCliente'] != null) noteParts.add('nome:${data['nomeCliente']}');
    final note = noteParts.join(' ');

    return Ordine(
      id: id,
      numeroTavolo: tavolo,
      pietanze: pietanze,
      stato: stato,
      timestamp: timestamp,
      idCameriere: idCameriere,
      note: note,
    );
  }
}
