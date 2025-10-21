import '../../models/pietanza_model.dart';
import '../../models/categoria_model.dart';

class MenuCacheService {
  List<Pietanza> _pietanzeMenu = [];
  List<Categoria> _categorieMenu = [];
  List<Map<String, dynamic>> _offerteMenu = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  DateTime _lastUpdate = DateTime.now();

  // 🔥 GETTERS
  List<Pietanza> get pietanzeMenu => List.from(_pietanzeMenu);
  List<Categoria> get categorieMenu => List.from(_categorieMenu);
  List<Map<String, dynamic>> get offerteMenu => List.from(_offerteMenu);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // 🔥 CONTROLLO CACHE
  bool shouldUseCache() {
    return _isInitialized && 
           DateTime.now().difference(_lastUpdate).inMinutes < 5;
  }

  // 🔥 AGGIORNA DATI
  void aggiornaDati({
    required List<Pietanza> pietanze,
    required List<Categoria> categorie,
    required List<Map<String, dynamic>> offerte,
  }) {
    _pietanzeMenu = pietanze;
    _categorieMenu = categorie;
    _offerteMenu = offerte;
    _isInitialized = true;
    _lastUpdate = DateTime.now();
  }

  // 🔥 GESTIONE LOADING
  void setLoading(bool loading) {
    _isLoading = loading;
  }

  // 🔥 AGGIORNA SINGOLA PIETANZA
  void aggiornaPietanza(Pietanza pietanza) {
    final index = _pietanzeMenu.indexWhere((p) => p.id == pietanza.id);
    if (index >= 0) {
      _pietanzeMenu[index] = pietanza;
    } else {
      _pietanzeMenu.add(pietanza);
    }
    _lastUpdate = DateTime.now();
  }

  // 🔥 AGGIORNA SINGOLA CATEGORIA
  void aggiornaCategoria(Categoria categoria) {
    final index = _categorieMenu.indexWhere((c) => c.id == categoria.id);
    if (index >= 0) {
      _categorieMenu[index] = categoria;
    } else {
      _categorieMenu.add(categoria);
    }
    _lastUpdate = DateTime.now();
  }

  // 🔥 RIMUOVI CATEGORIA
  void rimuoviCategoria(String categoriaId) {
    _categorieMenu.removeWhere((c) => c.id == categoriaId);
    _lastUpdate = DateTime.now();
  }

  // 🔥 AGGIORNA ORDINAMENTO CATEGORIE
  void aggiornaOrdinamentoCategorie(List<Categoria> categorieOrdinate) {
    _categorieMenu = categorieOrdinate;
    _lastUpdate = DateTime.now();
  }

  // 🔥 AGGIORNA ORDINAMENTO PIETANZE
  void aggiornaOrdinamentoMenu(List<Pietanza> pietanzeOrdinate) {
    _pietanzeMenu = pietanzeOrdinate;
    _lastUpdate = DateTime.now();
  }

  // 🔥 GESTIONE OFFERTE
  void aggiornaOfferta(Map<String, dynamic> offerta) {
    final index = _offerteMenu.indexWhere((o) => o['id'] == offerta['id']);
    if (index >= 0) {
      _offerteMenu[index] = offerta;
    } else {
      _offerteMenu.add(offerta);
    }
    _lastUpdate = DateTime.now();
  }

  void rimuoviOfferta(String offertaId) {
    _offerteMenu.removeWhere((o) => o['id'] == offertaId);
    _lastUpdate = DateTime.now();
  }

  void aggiornaOrdinamentoOfferte(List<Map<String, dynamic>> offerteOrdinate) {
    _offerteMenu = offerteOrdinate;
    _lastUpdate = DateTime.now();
  }

  // 🔥 RESET CACHE
  void reset() {
    _pietanzeMenu.clear();
    _categorieMenu.clear();
    _offerteMenu.clear();
    _isInitialized = false;
    _isLoading = false;
    _lastUpdate = DateTime.now();
  }
}