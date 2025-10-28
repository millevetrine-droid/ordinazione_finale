import 'package:ordinazione/core/services/firebase_service.dart' as core_fb;
import 'package:ordinazione/core/services/point_service.dart' as core_points;

/// Shim that delegates legacy imports to the canonical `lib_new` PointsService.
/// This keeps legacy import paths working while using the consolidated
/// implementation under `lib_new`.
class PointsService {
  late final core_points.PointsService _impl;

  PointsService() {
    final firestore = core_fb.FirebaseService().firestore;
    _impl = core_points.PointsService(firestore);
  }

  Future<Map<String, dynamic>> regalaPunti({
    required String daTelefono,
    required String aTelefono,
    required int punti,
    String? messaggio,
  }) async {
    return await _impl.regalaPunti(
      daTelefono: daTelefono,
      aTelefono: aTelefono,
      punti: punti,
      messaggio: messaggio,
    );
  }

  Stream<List<Map<String, dynamic>>> getRegaliInviati(String telefono) {
    return _impl.getRegaliInviati(telefono);
  }

  Stream<List<Map<String, dynamic>>> getRegaliRicevuti(String telefono) {
    return _impl.getRegaliRicevuti(telefono);
  }

  Future<void> aggiornaPuntiCliente(String telefono, int nuoviPunti) async {
    await _impl.aggiornaPuntiCliente(telefono, nuoviPunti);
  }

  Future<Map<String, dynamic>?> getClienteByTelefono(String telefono) async {
    return await _impl.getClienteByTelefono(telefono);
  }
}