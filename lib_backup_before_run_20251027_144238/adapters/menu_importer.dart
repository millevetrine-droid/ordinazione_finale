import '../services/firebase/menu_cache_service.dart';
import '../models/pietanza_model.dart';
import '../models/categoria_model.dart';
import 'menu_service_adapter.dart';
import 'offerta_adapter.dart';

/// Importer that accepts a Map structure (as produced by lib_new's menu loader)
/// and updates the local cache using the project's `MenuCacheService`.
class MenuImporter {
  final MenuCacheService _cache;

  MenuImporter(this._cache);

  /// data expected: {'pietanze': [...], 'categorie': [...], 'offerte': [...]}
  void importFromNewSource(Map<String, dynamic> data) {
    final pietanzeRaw = data['pietanze'] as List<dynamic>? ?? [];
    final categorieRaw = data['categorie'] as List<dynamic>? ?? [];
    final offerteRaw = data['offerte'] as List<dynamic>? ?? [];

    final List<Pietanza> pietanze = MenuServiceAdapter.pietanzeFromNewList(pietanzeRaw);
    final List<Categoria> categorie = MenuServiceAdapter.categorieFromNewList(categorieRaw);
  final List<Map<String, dynamic>> offerte = offerteRaw.map((e) => OffertaAdapter.fromNewMap(Map<String, dynamic>.from(e as Map))).toList();

    _cache.aggiornaDati(pietanze: pietanze, categorie: categorie, offerte: offerte);
  }
}
