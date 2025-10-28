import '../../models/pietanza_model.dart';
import '../../models/categoria_model.dart';
import 'menu_cache_service.dart';

class MenuDataService {
  // 🔥 METODI GETTER
  List<Categoria> getMacrocategorie(List<Categoria> categorieMenu) {
    return categorieMenu.where((c) => c.tipo == 'macrocategoria').toList();
  }

  List<Categoria> getSottocategorie(List<Categoria> categorieMenu, String idMacrocategoria) {
    return categorieMenu.where((c) => c.tipo == 'sottocategoria' && c.idPadre == idMacrocategoria).toList();
  }

  List<Pietanza> getPietanzeByCategoria(List<Pietanza> pietanzeMenu, String categoriaId) {
    return pietanzeMenu.where((p) => p.categoriaId == categoriaId).toList();
  }

  Pietanza? getPietanzaById(List<Pietanza> pietanzeMenu, String id) {
    try {
      return pietanzeMenu.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // 🔥 METODI AGGIORNAMENTO LOCALE
  void aggiornaCategoriaLocale(MenuCacheService cache, Categoria categoria) {
    cache.aggiornaCategoria(categoria);
  }

  void aggiornaPietanzaLocale(MenuCacheService cache, Pietanza pietanza) {
    cache.aggiornaPietanza(pietanza);
  }

  void aggiornaOffertaLocale(MenuCacheService cache, Map<String, dynamic> offerta) {
    cache.aggiornaOfferta(offerta);
  }

  void rimuoviCategoriaLocale(MenuCacheService cache, String categoriaId) {
    cache.rimuoviCategoria(categoriaId);
  }

  void rimuoviOffertaLocale(MenuCacheService cache, String offertaId) {
    cache.rimuoviOfferta(offertaId);
  }

  void aggiornaOrdinamentoCategorieLocale(MenuCacheService cache, List<Categoria> categorieOrdinate) {
    // Il cache service si occupa già dell'ordinamento
  }

  void aggiornaOrdinamentoMenuLocale(MenuCacheService cache, List<Pietanza> pietanzeOrdinate) {
    // Il cache service si occupa già dell'ordinamento
  }

  void aggiornaOrdinamentoOfferteLocale(MenuCacheService cache, List<Map<String, dynamic>> offerteOrdinate) {
    // Il cache service si occupa già dell'ordinamento
  }
}