import '../models/sessione_model.dart';

class QrGeneratorService {
  static String generaIdSessione() {
    return 'SESS${DateTime.now().millisecondsSinceEpoch}${_generaCodiceCasuale(6)}';
  }

  static String generaCodiceSessione() {
    return _generaCodiceCasuale(8).toUpperCase();
  }

  static String _generaCodiceCasuale(int lunghezza) {
    const caratteri = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer();
    
    for (var i = 0; i < lunghezza; i++) {
      buffer.write(caratteri[(random + i) % caratteri.length]);
    }
    
    return buffer.toString();
  }

  static SessioneTavolo creaSessione({
    required int numeroTavolo,
    required String idCameriere,
    Duration durata = const Duration(hours: 3),
  }) {
    final now = DateTime.now();
    
    return SessioneTavolo(
      id: generaIdSessione(),
      numeroTavolo: numeroTavolo,
      codiceSessione: generaCodiceSessione(),
      dataCreazione: now,
      dataScadenza: now.add(durata),
      idCameriere: idCameriere,
      attiva: true,
    );
  }

  static String generaDeepLink(SessioneTavolo sessione) {
    return 'magnorestaurant://ordina?tavolo=${sessione.numeroTavolo}&sessione=${sessione.codiceSessione}';
  }

  static (int?, String?) parseDeepLink(String deepLink) {
    try {
      final uri = Uri.parse(deepLink);
      if (uri.scheme == 'magnorestaurant' && uri.host == 'ordina') {
        final tavolo = int.tryParse(uri.queryParameters['tavolo'] ?? '');
        final sessione = uri.queryParameters['sessione'];
        return (tavolo, sessione);
      }
    } catch (e) {
      return (null, null);
    }
    return (null, null);
  }

  static bool isValidDeepLink(String deepLink) {
    final (tavolo, sessione) = parseDeepLink(deepLink);
    return tavolo != null && sessione != null && sessione.isNotEmpty;
  }
}