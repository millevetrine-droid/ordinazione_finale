import 'dart:async'; // 👈 AGGIUNTO PER TIMEOUTEXCEPTION
import 'dart:developer' as dev;
import '../../models/pietanza_model.dart';
import '../../models/categoria_model.dart';

// Import dei servizi modulari
import 'menu_cache_service.dart';
import 'menu_firestore_service.dart';
import 'menu_data_service.dart';
import 'menu_test_data_service.dart';

class MenuService {
  // 🔥 SERVIZI MODULARI
  final MenuCacheService _cache = MenuCacheService();
  final MenuFirestoreService _firestoreService = MenuFirestoreService();
  final MenuDataService _dataService = MenuDataService();
  final MenuTestDataService _testDataService = MenuTestDataService();

  // 🔥 GETTER SICURI
  List<Pietanza> get pietanzeMenu => _cache.pietanzeMenu;
  List<Categoria> get categorieMenu => _cache.categorieMenu;
  List<Map<String, dynamic>> get offerteMenu => _cache.offerteMenu;
  
  bool get isLoading => _cache.isLoading;
  bool get isInitialized => _cache.isInitialized;

  // 🔥 INIZIALIZZAZIONE PRINCIPALE
  Future<void> inizializzaMenu({bool forceRefresh = false}) async {
    if (_cache.isLoading) return;
    
    // Controllo cache
    if (!forceRefresh && _cache.shouldUseCache()) {
      dev.log('📦 Menu da cache - dati recenti', name: 'MenuService');
      return;
    }

    _cache.setLoading(true);
  dev.log('🔄 Caricamento menu da Firestore...', name: 'MenuService');

    try {
      // Caricamento parallelo con timeout
      final results = await Future.wait([
        _firestoreService.caricaTuttiIDati().timeout(const Duration(seconds: 10)),
      ], eagerError: true);

      final data = results[0];
      
      // Aggiorna cache
      _cache.aggiornaDati(
        pietanze: data['pietanze'] as List<Pietanza>,
        categorie: data['categorie'] as List<Categoria>,
        offerte: data['offerte'] as List<Map<String, dynamic>>,
      );
      
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

  // 🔥 METODI GETTER OTTIMIZZATI
  List<Categoria> getMacrocategorie() {
    return _dataService.getMacrocategorie(_cache.categorieMenu);
  }

  List<Categoria> getSottocategorie(String idMacrocategoria) {
    return _dataService.getSottocategorie(_cache.categorieMenu, idMacrocategoria);
  }

  List<Pietanza> getPietanzeByCategoria(String categoriaId) {
    return _dataService.getPietanzeByCategoria(_cache.pietanzeMenu, categoriaId);
  }

  // 🔥 METODI SALVATAGGIO OTTIMIZZATI
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

  // 🔥 METODI OFFERTE
  Future<void> salvaOfferta(Map<String, dynamic> offerta) async {
    await _firestoreService.salvaOfferta(offerta);
    _dataService.aggiornaOffertaLocale(_cache, offerta);
  }

  Future<void> eliminaOfferta(String offertaId) async {
    await _firestoreService.eliminaOfferta(offertaId);
    _dataService.rimuoviOffertaLocale(_cache, offertaId);
  }

  Future<void> aggiornaOrdinamentoOfferte(List<Map<String, dynamic>> offerteOrdinate) async {
    await _firestoreService.aggiornaOrdinamentoOfferte(offerteOrdinate);
    _dataService.aggiornaOrdinamentoOfferteLocale(_cache, offerteOrdinate);
  }

  // 🔥 METODI STATICI
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