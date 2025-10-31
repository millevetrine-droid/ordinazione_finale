import 'package:ordinazione/core/services/menu_services/menu_service.dart';
import 'package:ordinazione/adapters/offerta_adapter.dart';
import 'dart:developer' as dev;

class GestioneOfferteController {
  final List<Map<String, dynamic>> _offerte = [];
  final List<Map<String, dynamic>> _categorie = [];
  final List<Map<String, dynamic>> _pietanze = [];
  
  List<Map<String, dynamic>> get offerte => _offerte;
  List<Map<String, dynamic>> get categorie => _categorie;
  List<Map<String, dynamic>> get pietanze => _pietanze;

  Future<void> caricaDati() async {
    try {
      final menuService = await _inizializzaMenuService();
      final offerte = await MenuService.getOfferteStatic();

      _categorie.clear();
      _categorie.addAll(menuService.categorieMenu.map((cat) => {
        'id': cat.id,
        'nome': cat.nome,
        'tipo': cat.tipo,
      }));

      _pietanze.clear();
      _pietanze.addAll(menuService.pietanzeMenu.map((piet) => {
        'id': piet.id,
        'nome': piet.nome,
        'categoria': piet.categoriaId,
      }));

      _offerte.clear();
      _offerte.addAll(offerte);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> salvaOfferta(Map<String, dynamic> offerta) async {
    dev.log('GestioneOfferteController: salvaOfferta START id=${offerta['id']}', name: 'GestioneOfferteController');
    MenuService menuService;
    try {
      menuService = await _inizializzaMenuService();
    } catch (e) {
      // If initialization fails (e.g. Firestore temporarily unavailable),
      // fall back to the singleton instance so we can at least update the
      // local cache and emit the offerte stream.
      dev.log('⚠️ GestioneOfferteController: inizializzaMenuService failed: $e - falling back to MenuService()', name: 'GestioneOfferteController');
      menuService = MenuService();
    }

    final normalized = OffertaAdapter.fromNewMap(offerta);
    try {
      await menuService.salvaOfferta(normalized);
      dev.log('GestioneOfferteController: salvaOfferta DONE id=${offerta['id']}', name: 'GestioneOfferteController');
    } catch (e) {
      dev.log('❌ GestioneOfferteController: salvaOfferta ERROR: $e', name: 'GestioneOfferteController');
      rethrow;
    }
  }

  Future<void> eliminaOfferta(String idOfferta) async {
    final menuService = await _inizializzaMenuService();
    await menuService.eliminaOfferta(idOfferta);
    // Also remove locally from the controller list so the owner UI updates
    // immediately without waiting for a full reload.
    _offerte.removeWhere((o) => o['id'] == idOfferta);
  }

  /// Add or replace an offerta in the controller's local list. This is a
  /// lightweight helper that UI screens can call to reflect an optimistic
  /// local update while remote persistence occurs.
  void aggiungiOffertaLocale(Map<String, dynamic> offerta) {
    final index = _offerte.indexWhere((o) => o['id'] == offerta['id']);
    if (index >= 0) {
      _offerte[index] = offerta;
    } else {
      _offerte.add(offerta);
    }
  }

  Future<MenuService> _inizializzaMenuService() async {
    final menuService = MenuService();
    await menuService.inizializzaMenu();
    return menuService;
  }

  String getTipoLinkTesto(String linkTipo, String linkDestinazione) {
    switch (linkTipo) {
      case 'categoria':
        final categoria = _categorie.firstWhere(
          (cat) => cat['id'] == linkDestinazione, 
          orElse: () => {'nome': 'Sconosciuta'}
        );
        return '→ Categoria: ${categoria['nome']}';
      case 'pietanza':
        final pietanza = _pietanze.firstWhere(
          (piet) => piet['id'] == linkDestinazione, 
          orElse: () => {'nome': 'Sconosciuta'}
        );
        return '→ Pietanza: ${pietanza['nome']}';
      case 'ordina':
        return '→ Diretto all\'ordine';
      default:
        return '→ Link: $linkDestinazione';
    }
  }
}
