/*
 Adapter to convert between the new external Pietanza shape (from lib_new)
 and the existing project's `Pietanza` model.

 This file intentionally does not import types from `lib_new` so it keeps
 `lib_new` isolated in its sandbox. It accepts raw `Map<String, dynamic>`
 representations (the common serialization format) and produces the
 project's `Pietanza` instances. This makes integration incremental and
 low-risk.
*/

import '../models/pietanza_model.dart';

class PietanzaAdapter {
  /// Convert a Map produced by the new code (lib_new) into the local `Pietanza`.
  ///
  /// The adapter handles common differences between the schemas:
  /// - `imageUrl` (new) -> `immagine` (local)
  /// - `macrocategoriaId` or `categoriaId` -> `categoria`
  /// - `allergeni` as List<String> -> comma-separated String for the local model
  /// - numeric conversions and missing-field fallbacks
  static Pietanza fromNewMap(Map<String, dynamic> m) {
    final id = (m['id'] ?? '') as String;
    final nome = (m['nome'] ?? '') as String;
    final prezzo = (m['prezzo'] is num) ? (m['prezzo'] as num).toDouble() : 0.0;
    final descrizione = (m['descrizione'] ?? '') as String;

    // Prefer explicit categoriaId from new model; fall back to macrocategoriaId
    final categoriaId = (m['categoriaId'] ?? m['macrocategoriaId'] ?? '') as String;
    final categoria = (m['macrocategoriaId'] ?? m['categoria'] ?? categoriaId ?? '') as String;

    // imageUrl is the new common field name; immagine is used in current project
    final imageUrl = (m['imageUrl'] ?? m['immagine']) as String?;
    final immagine = imageUrl ?? '';

    // ordine may be absent in the new model; default to 0
    final ordine = (m['ordine'] is int) ? m['ordine'] as int : (m['ordine'] is num ? (m['ordine'] as num).toInt() : 0);

    final usaFoto = (m['usaFoto'] is bool) ? m['usaFoto'] as bool : (imageUrl != null && imageUrl.isNotEmpty);
    final fotoUrl = imageUrl;

    // New model may have allergeni as List<String>. Map to a single String for
    // backward compatible local model (comma separated). If allergeni is already
    // a String, keep it.
    String? allergeni;
    final rawAll = m['allergeni'];
    if (rawAll is String) {
      allergeni = rawAll;
    } else if (rawAll is Iterable) {
      try {
        allergeni = rawAll.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).join(', ');
        if (allergeni.isEmpty) allergeni = null;
      } catch (_) {
        allergeni = null;
      }
    } else {
      allergeni = null;
    }

    return Pietanza(
      id: id,
      nome: nome,
      prezzo: prezzo,
      categoria: categoria,
      categoriaId: categoriaId,
      descrizione: descrizione,
      immagine: immagine,
      ordine: ordine,
      usaFoto: usaFoto,
      fotoUrl: fotoUrl,
      allergeni: allergeni,
    );
  }

  /// Convert a local `Pietanza` to a Map compatible with the new code.
  /// This is useful when sending data back to services from lib_new.
  static Map<String, dynamic> toNewMap(Pietanza p) {
    return {
      'id': p.id,
      'nome': p.nome,
      'prezzo': p.prezzo,
      'descrizione': p.descrizione,
      'imageUrl': p.fotoUrl ?? (p.immagine.isNotEmpty ? p.immagine : null),
      'ingredienti': [], // adapter can't infer ingredients; leave empty by default
      'allergeni': p.allergeni != null ? p.allergeni!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() : [],
      'disponibile': true,
      'stato': 0,
      'categoriaId': p.categoriaId,
      'macrocategoriaId': p.categoria,
    };
  }
}
