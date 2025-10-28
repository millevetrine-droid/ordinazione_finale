import 'package:ordinazione/services/firebase/menu_cache_service.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'package:ordinazione/core/models/categoria_model.dart';

/// Minimal compatibility importer used by smoke tests.
class MenuImporter {
  final MenuCacheService _cache;

  MenuImporter(this._cache);

  /// Expects a map with keys 'pietanze', 'categorie', 'offerte'.
  void importFromNewSource(Map<String, dynamic> source) {
    final pietanzeRaw = (source['pietanze'] as List? ?? const []).cast<Map<String, dynamic>>();
    final categorieRaw = (source['categorie'] as List? ?? const []).cast<Map<String, dynamic>>();
    final offerteRaw = (source['offerte'] as List? ?? const []).cast<Map<String, dynamic>>();

    final pietanze = pietanzeRaw.map((m) => Pietanza.fromMap(m)).toList();
    final categorie = categorieRaw.map((m) {
      // Ensure required macrocategoriaId exists in new core model
      final map = Map<String, dynamic>.from(m);
      map['macrocategoriaId'] = map['macrocategoriaId'] ?? (map['idPadre'] ?? map['id'] ?? '');
      return Categoria.fromMap(map);
    }).toList();

    _cache.aggiornaDati(
      pietanze: pietanze,
      categorie: categorie,
      offerte: offerteRaw,
    );
  }
}
