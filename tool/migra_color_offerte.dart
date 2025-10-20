import 'dart:io';
import 'package:ordinazione/services/firebase/menu_firestore_service.dart';

/// Script CLI per lanciare la migrazione dalle offerte.
/// Eseguire con:
/// dart run tool/migra_color_offerte.dart
/// Nota: richiede che le credenziali Firebase siano disponibili per l'ambiente.
Future<void> main() async {
  final service = MenuFirestoreService();
  stdout.writeln('Eseguo migrazione colori offerte...');
  try {
    final updated = await service.migraColoriOfferte();
    stdout.writeln('Migrazione completata. Documenti aggiornati: $updated');
    exitCode = 0;
  } catch (e, st) {
    stderr.writeln('Errore durante la migrazione: $e');
    stderr.writeln(st);
    exitCode = 1;
  }
}
