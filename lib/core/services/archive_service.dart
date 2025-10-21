import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase/archive_service.dart' as legacy;

/// Bridge ArchiveService to provide the API expected by `lib_new` UI.
class ArchiveService {
  final legacy.ArchiveService legacyService = legacy.ArchiveService();

  ArchiveService(FirebaseFirestore firestore) {
    // legacy service uses its internal Firestore instance; constructor kept for API parity
  }

  Stream<List<Map<String, dynamic>>> getArchivioCucina() {
    return legacyService.getArchivioCucina();
  }

  Stream<List<Map<String, dynamic>>> getArchivioSala() {
    return legacyService.getArchivioSala();
  }

  Future<void> archiviaPietanzaPronta({
    required String ordineId,
    required int indicePietanza,
    required Map<String, dynamic> pietanza,
    required String tavolo,
  }) async {
    await legacyService.archiviaPietanzaPronta(
      ordineId: ordineId,
      indicePietanza: indicePietanza,
      pietanza: pietanza,
      tavolo: tavolo,
    );
  }

  Future<void> archiviaPietanzaConsegnata({
    required String ordineId,
    required int indicePietanza,
    required Map<String, dynamic> pietanza,
    required String tavolo,
  }) async {
    await legacyService.archiviaPietanzaConsegnata(
      ordineId: ordineId,
      indicePietanza: indicePietanza,
      pietanza: pietanza,
      tavolo: tavolo,
    );
  }

  Future<void> ripristinaPietanzaDaArchivio(String archivioId) async {
    await legacyService.ripristinaPietanzaDaArchivio(archivioId);
  }

  Future<void> ripristinaPietanzaDaArchivioSala(String archivioId) async {
    await legacyService.ripristinaPietanzaDaArchivioSala(archivioId);
  }
}
