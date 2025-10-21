import '../../models/pietanza_model.dart';
import '../../models/categoria_model.dart';

class MenuCacheService {
  List<Pietanza> _pietanzeMenu = [];
  List<Categoria> _categorieMenu = [];
  List<Map<String, dynamic>> _offerteMenu = [];
  
  bool _isLoading = false;
  bool _isInitialized = false;
  DateTime? _lastUpdate;

  // GETTER SICURI
  List<Pietanza> get pietanzeMenu => List.from(_pietanzeMenu);
  List<Categoria> get categorieMenu => List.from(_categorieMenu);
  List<Map<String, dynamic>> get offerteMenu => List.from(_offerteMenu);
  
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // CONTROLLO CACHE
  bool shouldUseCache() {
    return _isInitialized && 
           _lastUpdate != null && 
           DateTime.now().difference(_lastUpdate!).inMinutes < 5;
  }

  // AGGIORNAMENTO DATI
  void aggiornaDati({
    required List<Pietanza> pietanze,
    required List<Categoria> categorie,
    required List<Map<String, dynamic>> offerte,
  }) {
    _pietanzeMenu = pietanze;
    _categorieMenu = categorie;
    _offerteMenu = offerte;
    
    _ordinaDati();
    _isInitialized = true;
    _lastUpdate = DateTime.now();
  }

  // ORDINAMENTO
  void _ordinaDati() {
    _categorieMenu.sort((a, b) => a.ordine.compareTo(b.ordine));
    _pietanzeMenu.sort((a, b) => a.ordine.compareTo(b.ordine));
    _offerteMenu.sort((a, b) => (a['ordine'] as int).compareTo(b['ordine'] as int));
  }

  // CONTROLLO CARICAMENTO
  void setLoading(bool loading) {
    _isLoading = loading;
  }

  // AGGIORNAMENTO SINGOLI ELEMENTI
  void aggiornaPietanza(Pietanza pietanza) {
    final index = _pietanzeMenu.indexWhere((p) => p.id == pietanza.id);
    if (index >= 0) {
      _pietanzeMenu[index] = pietanza;
    } else {
      _pietanzeMenu.add(pietanza);
    }
    _pietanzeMenu.sort((a, b) => a.ordine.compareTo(b.ordine));
  }

  void aggiornaCategoria(Categoria categoria) {
    final index = _categorieMenu.indexWhere((c) => c.id == categoria.id);
    if (index >= 0) {
      _categorieMenu[index] = categoria;
    } else {
      _categorieMenu.add(categoria);
    }
    _categorieMenu.sort((a, b) => a.ordine.compareTo(b.ordine));
  }

  void aggiornaOfferta(Map<String, dynamic> offerta) {
    final index = _offerteMenu.indexWhere((o) => o['id'] == offerta['id']);
    if (index >= 0) {
      _offerteMenu[index] = offerta;
    } else {
      _offerteMenu.add(offerta);
    }
    _offerteMenu.sort((a, b) => (a['ordine'] as int).compareTo(b['ordine'] as int));
  }

  // RIMOZIONE ELEMENTI
  void rimuoviCategoria(String categoriaId) {
    _categorieMenu.removeWhere((c) => c.id == categoriaId);
  }

  void rimuoviOfferta(String offertaId) {
    _offerteMenu.removeWhere((o) => o['id'] == offertaId);
  }
}