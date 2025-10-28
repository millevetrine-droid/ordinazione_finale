import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase/points_service.dart' as legacy;

/// Bridge PointsService to provide the API expected by `lib_new` UI.
/// Delegates to the legacy, tested PointsService implementation.
class PointsService {
  final legacy.PointsService legacyService = legacy.PointsService();

  // keep the same constructor signature as lib_new expects
  PointsService(FirebaseFirestore firestore) {
    // firestore param is ignored because legacy service uses its own instance
  }

  Future<Map<String, dynamic>> regalaPunti({
    required String daTelefono,
    required String aTelefono,
    required int punti,
    String? messaggio,
  }) async {
    return await legacyService.regalaPunti(
      daTelefono: daTelefono,
      aTelefono: aTelefono,
      punti: punti,
      messaggio: messaggio,
    );
  }

  Stream<List<Map<String, dynamic>>> getRegaliInviati(String telefono) {
    return legacyService.getRegaliInviati(telefono);
  }

  Stream<List<Map<String, dynamic>>> getRegaliRicevuti(String telefono) {
    return legacyService.getRegaliRicevuti(telefono);
  }

  Future<void> aggiungiPunti(String telefono, int punti) async {
    // Legacy service exposes aggiornaPuntiCliente; use it for compatibility
    await legacyService.aggiornaPuntiCliente(telefono, punti);
  }
}
