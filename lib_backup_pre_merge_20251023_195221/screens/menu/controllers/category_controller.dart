import '../../../services/firebase_service.dart';
import '../../../models/pietanza_model.dart';
import '../../../models/categoria_model.dart';

class CategoryController {
  String? categoriaSelezionata;

  void initState() {
    final categorie = getCategoriePerMenu();
    if (categorie.isNotEmpty) {
      categoriaSelezionata = categorie.first.id;
    }
  }

  List<Categoria> getCategoriePerMenu() {
    final macrocategorie = FirebaseService.menu.getMacrocategorie();
    final categorieConPietanze = <Categoria>[];

    for (final macro in macrocategorie) {
      final pietanzeMacro = FirebaseService.menu.pietanzeMenu.where((p) => p.categoriaId == macro.id).toList();
      if (pietanzeMacro.isNotEmpty) {
        categorieConPietanze.add(macro);
      }

      final sottocategorie = FirebaseService.menu.getSottocategorie(macro.id);
      for (final sotto in sottocategorie) {
        final pietanzeSotto = FirebaseService.menu.pietanzeMenu.where((p) => p.categoriaId == sotto.id).toList();
        if (pietanzeSotto.isNotEmpty) {
          categorieConPietanze.add(sotto);
        }
      }
    }

    return categorieConPietanze;
  }

  List<Pietanza> getPietanzePerCategoria(String? categoriaId) {
    if (categoriaId == null) {
      return FirebaseService.menu.pietanzeMenu;
    }
    return FirebaseService.menu.pietanzeMenu.where((p) => p.categoriaId == categoriaId).toList();
  }
}