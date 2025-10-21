import 'dart:convert';
import 'dart:io';

import 'package:googleapis/firestore/v1.dart' as firestore_api;
import 'package:googleapis_auth/auth_io.dart';

/// Pure-Dart migration CLI for converting integer colors in `offerte` to
/// hex strings '#AARRGGBB'.
///
/// Usage:
///   dart run tool/migra_color_offerte.dart --dry-run
///   dart run tool/migra_color_offerte.dart
///
/// The environment variable GOOGLE_APPLICATION_CREDENTIALS must point to a
/// service account JSON key with access to Firestore.

const _scopes = [firestore_api.FirestoreApi.datastoreScope];

Future<void> main(List<String> args) async {
  final bool dryRun = args.contains('--dry-run') || args.contains('-n');
  int? sampleCount;
  if (args.contains('--sample')) {
    final idx = args.indexOf('--sample');
    if (idx + 1 < args.length) sampleCount = int.tryParse(args[idx + 1]);
  } else if (args.contains('-s')) {
    final idx = args.indexOf('-s');
    if (idx + 1 < args.length) sampleCount = int.tryParse(args[idx + 1]);
  }
  if (dryRun) {
    stdout.writeln('Dry-run: conto i documenti che verrebbero aggiornati (nessuna scrittura).');
  } else {
    stdout.writeln('Eseguo migrazione colori offerte...');
  }

  final credPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
  if (credPath == null || credPath.isEmpty) {
    stderr.writeln('Errore: GOOGLE_APPLICATION_CREDENTIALS non impostato o vuoto.');
    exitCode = 2;
    return;
  }

  final credFile = File(credPath);
  if (!await credFile.exists()) {
    stderr.writeln('Errore: file di credenziali non trovato: $credPath');
    exitCode = 3;
    return;
  }

  final jsonContent = json.decode(await credFile.readAsString());

  final accountCredentials = ServiceAccountCredentials.fromJson(jsonContent);

  final client = await clientViaServiceAccount(accountCredentials, _scopes);
  final api = firestore_api.FirestoreApi(client);

  try {
    // Derive project and database name from credentials/project_id
    final projectId = jsonContent['project_id'] as String?;
    if (projectId == null) {
      stderr.writeln('Errore: project_id non trovato nelle credenziali.');
      exitCode = 4;
      return;
    }
    final database = 'projects/$projectId/databases/(default)';

    // 1) List documents in `offerte` collection
    final parent = '$database/documents';
    const collectionId = 'offerte';

  int updated = 0;
  int intCount = 0;
  int doubleCount = 0;
  int stringNumericCount = 0;
  int otherCount = 0;
    const pageSize = 1000; // list page size
    String? nextPageToken;

    do {
    final resp = await api.projects.databases.documents.list(parent, collectionId,
      pageSize: pageSize, pageToken: nextPageToken);

      nextPageToken = resp.nextPageToken;
      final documents = resp.documents ?? [];

      // Inspect each document
      for (final doc in documents) {
        final fields = doc.fields ?? {};
        // If sample requested, print raw colore and doc name
        if (sampleCount != null && sampleCount > 0) {
          final coloreField = fields['colore'];
          stdout.writeln('DOC: ${doc.name}');
          stdout.writeln('  colore raw: ${coloreField == null ? '<missing>' : _describeValue(coloreField)}');
          sampleCount = sampleCount - 1;
          if (sampleCount <= 0) break;
          continue;
        }
        final coloreField = fields['colore'];
        if (coloreField == null) continue;

        // Classify colore field type
        final intVal = coloreField.integerValue;
        final dblVal = coloreField.doubleValue;
        final strVal = coloreField.stringValue;

        if (intVal != null) {
          intCount++;
          updated++;
          if (!dryRun) {
            // Convert int to hex #AARRGGBB (Firestore stores colors as ARGB int)
            int v;
            try {
              v = int.parse(intVal);
            } catch (e) {
              // If parse fails, try double/truncate
              try {
                v = double.parse(intVal).toInt();
              } catch (_) {
                continue;
              }
            }
            final hex = _intToHexAARRGGBB(v);

            // Prepare patch: update only the `colore` field to stringValue
            final commitRequest = firestore_api.CommitRequest(
              writes: [
                firestore_api.Write(
                  updateMask: null,
                  update: firestore_api.Document(
                    name: doc.name,
                    fields: {'colore': firestore_api.Value(stringValue: hex)},
                  ),
                )
              ],
            );

            // Send commit for single document
            await api.projects.databases.documents.commit(commitRequest, database);
          }
        } else if (dblVal != null) {
          doubleCount++;
          // consider double as potential numeric color (not counted as updated by current logic)
        } else if (strVal != null) {
          // if string holds digits, consider it numeric
          final parsed = int.tryParse(strVal);
          if (parsed != null) {
            stringNumericCount++;
            // numeric string - we don't count it as updated by the current integer-only migration
          } else {
            otherCount++;
          }
        } else {
          otherCount++;
        }
      }
    } while (nextPageToken != null && nextPageToken.isNotEmpty);

    // Summary report
    if (dryRun) {
      stdout.writeln('Dry-run completato. Documenti che sarebbero aggiornati (integerValue): $updated');
      stdout.writeln('Dettaglio tipi `colore`: integer=$intCount, double=$doubleCount, stringNumeric=$stringNumericCount, other=$otherCount');
    } else {
      stdout.writeln('Migrazione completata. Documenti aggiornati: $updated');
      stdout.writeln('Dettaglio tipi `colore` aggiornati (prima della migrazione): integer=$intCount, double=$doubleCount, stringNumeric=$stringNumericCount, other=$otherCount');
    }
    exitCode = 0;
  } catch (e, st) {
    stderr.writeln('Errore durante la migrazione: $e');
    stderr.writeln(st);
    exitCode = 1;
  } finally {
    client.close();
  }
}

String _toHex2(int v) => v.toRadixString(16).padLeft(2, '0');

String _intToHexAARRGGBB(int v) {
  // Assuming v is 32-bit ARGB like 0xAARRGGBB or 0xRRGGBB (no alpha)
  final a = ((v >> 24) & 0xff);
  final r = ((v >> 16) & 0xff);
  final g = ((v >> 8) & 0xff);
  final b = (v & 0xff);

  // If alpha is zero and v fits 24-bit, assume opaque
  final alpha = (a == 0) ? 0xff : a;

  return '#${_toHex2(alpha)}${_toHex2(r)}${_toHex2(g)}${_toHex2(b)}';
}

String _describeValue(firestore_api.Value v) {
  if (v.integerValue != null) return 'integerValue=${v.integerValue}';
  if (v.doubleValue != null) return 'doubleValue=${v.doubleValue}';
  if (v.stringValue != null) return 'stringValue=${v.stringValue}';
  if (v.booleanValue != null) return 'booleanValue=${v.booleanValue}';
  if (v.mapValue != null) return 'mapValue=${v.mapValue!.fields}';
  if (v.arrayValue != null) return 'arrayValue=${v.arrayValue!.values}';
  if (v.nullValue != null) return 'null';
  return '<unknown value representation>'; 
}

