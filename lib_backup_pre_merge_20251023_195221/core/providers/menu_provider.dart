import 'package:flutter/foundation.dart';
import '../repositories/menu_repository.dart';

class MenuProvider with ChangeNotifier {
  final MenuRepository _repo;

  MenuProvider(this._repo);

  bool _loading = false;
  List<Categoria> _macrocategorie = [];

  bool get loading => _loading;
  List<Categoria> get macrocategorie => List.unmodifiable(_macrocategorie);

  Future<void> loadMacrocategorie() async {
    _loading = true;
    notifyListeners();
    try {
      _macrocategorie = await _repo.fetchMacrocategorie();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<Categoria> getCategorieByMacrocategoria(String id) =>
      _macrocategorie.where((c) => c.id == id).toList();
}
