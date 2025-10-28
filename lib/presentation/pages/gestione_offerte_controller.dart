import 'package:ordinazione/core/services/menu_services/menu_service.dart';
import 'package:ordinazione/adapters/offerta_adapter.dart';

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
    final menuService = await _inizializzaMenuService();
    final normalized = OffertaAdapter.fromNewMap(offerta);
    await menuService.salvaOfferta(normalized);
  }

  Future<void> eliminaOfferta(String idOfferta) async {
    final menuService = await _inizializzaMenuService();
    await menuService.eliminaOfferta(idOfferta);
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
