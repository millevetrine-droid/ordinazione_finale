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
    // imageUrl is the new common field name; legacy field may be 'immagine' or 'emoji'
    final imageUrl = m['imageUrl'] as String?;
    final emojiField = (m['emoji'] ?? m['immagine']) as String?;

    // ordine may be absent in the new model; default to 0
    final ordine = (m['ordine'] is int)
        ? m['ordine'] as int
        : (m['ordine'] is num ? (m['ordine'] as num).toInt() : 0);

    // legacy 'categoria' variable is not used after migration to categoriaId/macrocategoriaId

    // New model may have allergeni as List<String> or as comma string. Normalize to List<String>
    final rawAll = m['allergeni'];
    final List<String> allergeniList = [];
    if (rawAll is String) {
      for (final s in rawAll.split(',')) {
        final t = s.trim();
        if (t.isNotEmpty) allergeniList.add(t);
      }
    } else if (rawAll is Iterable) {
      for (final e in rawAll) {
        final s = e?.toString();
        if (s != null && s.isNotEmpty) allergeniList.add(s);
      }
    }

    return Pietanza(
      id: id,
      nome: nome,
      descrizione: descrizione,
      prezzo: prezzo,
      emoji: emojiField,
      imageUrl: imageUrl,
      ingredienti: (() {
        final List<String> list = [];
        final raw = m['ingredienti'];
        if (raw is Iterable) {
          for (final e in raw) {
            final s = e?.toString();
            if (s != null && s.isNotEmpty) list.add(s);
          }
        }
        return list;
      })(),
    allergeni: allergeniList,
    disponibile: m['disponibile'] ?? true,
      categoriaId: categoriaId,
      macrocategoriaId: (m['macrocategoriaId'] ?? categoriaId) as String,
      ordine: ordine,
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
      'imageUrl': p.imageUrl ?? (p.emoji != null && p.emoji!.isNotEmpty ? p.emoji : null),
      'ingredienti': p.ingredienti,
      'allergeni': p.allergeni,
      'disponibile': p.disponibile,
      'stato': p.stato.index,
      'categoriaId': p.categoriaId,
      'macrocategoriaId': p.macrocategoriaId,
    };
  }
}
