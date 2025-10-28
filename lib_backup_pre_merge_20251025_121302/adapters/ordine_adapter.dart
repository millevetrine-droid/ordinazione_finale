import '../models/ordine_model.dart';

class OrdineAdapter {
  /// Convert a Map coming from lib_new into local `Ordine`.
  static Ordine fromNewMap(String id, Map<String, dynamic> m) {
    final tavolo = (m['tavolo'] ?? 'N/A') as String;
    final numeroPersone = (m['numeroPersone'] is int) ? m['numeroPersone'] as int : ((m['numeroPersone'] is num) ? (m['numeroPersone'] as num).toInt() : 1);

    final pietanzeRaw = m['pietanze'] as List? ?? [];
    final pietanze = pietanzeRaw.map((p) {
      final map = Map<String, dynamic>.from(p as Map);
      return PietanzaOrdine.fromMap(map);
    }).toList();

    final timestampRaw = m['timestamp'];
    DateTime timestamp;
    if (timestampRaw is DateTime) {
      timestamp = timestampRaw;
    } else if (timestampRaw is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(timestampRaw);
    } else {
      timestamp = DateTime.now();
    }

    final accumulaPunti = m['accumulaPunti'] ?? false;
    final statoComplessivo = m['statoComplessivo'] ?? 'in_attesa';

    final totale = pietanze.fold(0.0, (sum, p) => sum + (p.prezzo * p.quantita));

    return Ordine(
      id: id,
      tavolo: tavolo,
      pietanze: pietanze,
      timestamp: timestamp,
      numeroPersone: numeroPersone,
      telefonoCliente: m['telefonoCliente'],
      nomeCliente: m['nomeCliente'],
      accumulaPunti: accumulaPunti,
      statoComplessivo: statoComplessivo,
      totale: totale,
    );
  }
}
