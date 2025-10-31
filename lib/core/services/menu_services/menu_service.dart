import 'dart:async'; // for TimeoutException
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:developer' as dev;
import 'package:ordinazione/models/pietanza_model.dart';
import 'package:ordinazione/models/categoria_model.dart';

// Import dei servizi modulari
import 'package:ordinazione/core/services/menu_services/menu_cache_service.dart';
import 'package:ordinazione/core/services/menu_services/menu_firestore_service.dart';
import 'package:ordinazione/core/services/menu_services/menu_data_service.dart';
import 'package:ordinazione/core/services/menu_services/menu_test_data_service.dart';

class MenuService {
  // Make MenuService a simple singleton so different callers share the same
  // cache and streams. This keeps the cache consistent across UI reads and
  // ensures stream listeners receive updates when the cache changes.
  static final MenuService _instance = MenuService._internal();

  factory MenuService() => _instance;

  MenuService._internal();
  // SERVIZI MODULARI
  final MenuCacheService _cache = MenuCacheService();
  final MenuFirestoreService _firestoreService = MenuFirestoreService();
  final MenuDataService _dataService = MenuDataService();
  final MenuTestDataService _testDataService = MenuTestDataService();

  // Stream controller to broadcast offerte changes to UI listeners.
  final StreamController<List<Map<String, dynamic>>> _offerteController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get offerteStream => _offerteController.stream;

  /// Public helper to update the local offerte cache and notify listeners.
  /// Use this for optimistic updates from UI code when remote persistence may
  /// fail or be slow.
  void aggiornaOffertaLocaleEAvvisa(Map<String, dynamic> offerta) {
    try {
      dev.log('MenuService: aggiornaOffertaLocaleEAvvisa id=${offerta['id']}', name: 'MenuService');
    } catch (_) {}
    _dataService.aggiornaOffertaLocale(_cache, offerta);
    try {
      debugPrint('📦 (manual) Local cache aggiornata, offerte count=${_cache.offerteMenu.length}');
    } catch (_) {}
    try {
      _offerteController.add(_cache.offerteMenu);
      try {
        debugPrint('📣 (manual) Emitting offerte stream update');
      } catch (_) {}
    } catch (_) {}
  }

  // GETTER
  List<Pietanza> get pietanzeMenu => _cache.pietanzeMenu;
  List<Categoria> get categorieMenu => _cache.categorieMenu;
  List<Map<String, dynamic>> get offerteMenu => _cache.offerteMenu;

  bool get isLoading => _cache.isLoading;
  bool get isInitialized => _cache.isInitialized;

  // INIZIALIZZAZIONE
  Future<void> inizializzaMenu({bool forceRefresh = false}) async {
    if (_cache.isLoading) return;

    if (!forceRefresh && _cache.shouldUseCache()) {
      dev.log('📦 Menu da cache - dati recenti', name: 'MenuService');
      return;
    }

    _cache.setLoading(true);
    dev.log('🔄 Caricamento menu da Firestore...', name: 'MenuService');

    try {
      final results = await Future.wait([
        _firestoreService.caricaTuttiIDati().timeout(const Duration(seconds: 10)),
      ], eagerError: true);

  final data = results[0];

      _cache.aggiornaDati(
        pietanze: data['pietanze'] as List<Pietanza>,
        categorie: data['categorie'] as List<Categoria>,
        offerte: data['offerte'] as List<Map<String, dynamic>>,
      );

      // Publish initial offerte to any listeners
      try {
        _offerteController.add(_cache.offerteMenu);
      } catch (_) {}

      dev.log('✅ Menu OTTIMIZZATO: ${pietanzeMenu.length} pietanze, ${categorieMenu.length} categorie, ${offerteMenu.length} offerte', name: 'MenuService');
    } on TimeoutException {
      dev.log('⚠️ Timeout caricamento menu - uso dati esistenti', name: 'MenuService');
      if (!_cache.isInitialized) {
        _testDataService.caricaDatiDiTest(_cache);
      }
    } catch (e) {
      dev.log('❌ Errore caricamento menu: $e', name: 'MenuService');
      if (!_cache.isInitialized) {
        _testDataService.caricaDatiDiTest(_cache);
      }
    } finally {
      _cache.setLoading(false);
    }
  }

  // METODI GETTER UTILITARI
  List<Categoria> getMacrocategorie() {
    return _dataService.getMacrocategorie(_cache.categorieMenu);
  }

  List<Categoria> getSottocategorie(String idMacrocategoria) {
    return _dataService.getSottocategorie(_cache.categorieMenu, idMacrocategoria);
  }

  List<Pietanza> getPietanzeByCategoria(String categoriaId) {
    return _dataService.getPietanzeByCategoria(_cache.pietanzeMenu, categoriaId);
  }

  // METODI SALVATAGGIO / MUTAZIONE
  Future<void> salvaCategoria(Categoria categoria) async {
    await _firestoreService.salvaCategoria(categoria);
    _dataService.aggiornaCategoriaLocale(_cache, categoria);
  }

  Future<void> salvaPietanza(Pietanza pietanza) async {
    await _firestoreService.salvaPietanza(pietanza);
    _dataService.aggiornaPietanzaLocale(_cache, pietanza);
  }

  Future<void> eliminaCategoria(String categoriaId) async {
    await _firestoreService.eliminaCategoria(categoriaId, _cache.categorieMenu, _cache.pietanzeMenu);
    _dataService.rimuoviCategoriaLocale(_cache, categoriaId);
  }

  Future<void> aggiornaOrdinamentoCategorie(List<Categoria> categorieOrdinate) async {
    await _firestoreService.aggiornaOrdinamentoCategorie(categorieOrdinate);
    _dataService.aggiornaOrdinamentoCategorieLocale(_cache, categorieOrdinate);
  }

  Future<void> aggiornaOrdinamentoMenu(List<Pietanza> pietanzeOrdinate) async {
    await _firestoreService.aggiornaOrdinamentoMenu(pietanzeOrdinate);
    _dataService.aggiornaOrdinamentoMenuLocale(_cache, pietanzeOrdinate);
  }

  // OFFERTE
  Future<void> salvaOfferta(Map<String, dynamic> offerta) async {
    // Try to persist to Firestore, but ensure local cache is updated even if
    // the remote write fails (e.g. emulator down). This allows the UI to
    // reflect the newly created offer immediately and avoids blocking the
    // proprietor when Firestore is temporarily unavailable.
    dev.log('📥 MenuService.salvaOfferta called for id=${offerta['id']}', name: 'MenuService');
    try {
      debugPrint('📥 MenuService.salvaOfferta called for id=${offerta['id']}');
    } catch (_) {}
    try {
      await _firestoreService.salvaOfferta(offerta);
    } catch (e) {
      dev.log('⚠️ salvaOfferta remote write failed: $e', name: 'MenuService');
      try {
        debugPrint('⚠️ salvaOfferta remote write failed: $e');
      } catch (_) {}
      // proceed to update local cache so the offer appears in the UI
    }
    _dataService.aggiornaOffertaLocale(_cache, offerta);
    dev.log('📦 Local cache aggiornata, offerte count=${_cache.offerteMenu.length}', name: 'MenuService');
    try {
      debugPrint('📦 Local cache aggiornata, offerte count=${_cache.offerteMenu.length}');
    } catch (_) {}
    // Notify listeners that offerte changed so UI can update immediately.
    try {
      dev.log('📣 Emitting offerte stream update', name: 'MenuService');
      try {
        debugPrint('📣 Emitting offerte stream update');
      } catch (_) {}
      _offerteController.add(_cache.offerteMenu);
    } catch (_) {}
  }

  Future<void> eliminaOfferta(String offertaId) async {
    try {
      await _firestoreService.eliminaOfferta(offertaId);
    } catch (e) {
      // Remote delete failed (emulator/unavailable/permissions). Proceed
      // to remove locally so UI reflects the proprietor's intent.
      dev.log('⚠️ eliminaOfferta remote failed: $e', name: 'MenuService');
    }
    _dataService.rimuoviOffertaLocale(_cache, offertaId);
    // Notify listeners that the offerte list changed so UI can update.
    try {
      _offerteController.add(_cache.offerteMenu);
    } catch (_) {}
  }

  Future<void> aggiornaOrdinamentoOfferte(List<Map<String, dynamic>> offerteOrdinate) async {
    await _firestoreService.aggiornaOrdinamentoOfferte(offerteOrdinate);
    _dataService.aggiornaOrdinamentoOfferteLocale(_cache, offerteOrdinate);
  }

  // METODI STATICI CONVENIENTI
  static Future<List<Pietanza>> getMenu() async {
    final menuService = MenuService();
    await menuService.inizializzaMenu();
    return menuService.pietanzeMenu;
  }

  static Future<Pietanza?> getPietanzaById(String id) async {
    final menuService = MenuService();
    await menuService.inizializzaMenu();
    return menuService._dataService.getPietanzaById(menuService._cache.pietanzeMenu, id);
  }

  static Future<List<Map<String, dynamic>>> getOfferteStatic() async {
    final menuService = MenuService();
    await menuService.inizializzaMenu();
    return menuService.offerteMenu;
  }
}