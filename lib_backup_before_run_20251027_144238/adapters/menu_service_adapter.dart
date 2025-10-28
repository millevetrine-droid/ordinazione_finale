import '../models/pietanza_model.dart';
import '../models/categoria_model.dart';
import '../services/firebase/menu_service.dart' as existing;
import 'pietanza_adapter.dart';
import 'categoria_adapter.dart';

/// Facade adapter that provides a single integration point for menu data.
///
/// - By default it proxies to the existing `MenuService` implementation.
/// - It also exposes helpers to convert raw Maps (coming from the sandboxed
///   `lib_new`) to the local models using the adapters.
class MenuServiceAdapter {
  /// Initialize the canonical menu (delegates to existing service)
  static Future<void> inizializzaMenu({bool forceRefresh = false}) async {
    final svc = existing.MenuService();
    await svc.inizializzaMenu(forceRefresh: forceRefresh);
  }

  /// Get menu using existing service (delegates)
  static Future<List<Pietanza>> getMenu() async {
    return await existing.MenuService.getMenu();
  }

  /// Convert a raw list of maps coming from the new code into local Pietanza
  static List<Pietanza> pietanzeFromNewList(List<dynamic> raw) {
    return raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return PietanzaAdapter.fromNewMap(m);
    }).toList();
  }

  /// Convert a raw list of maps coming from the new code into local Categoria
  static List<Categoria> categorieFromNewList(List<dynamic> raw) {
    return raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return CategoriaAdapter.fromNewMap(m);
    }).toList();
  }
}
