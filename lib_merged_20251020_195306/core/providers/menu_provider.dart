import 'package:flutter/foundation.dart';
import '../repositories/menu_repository.dart';
import '../models/macrocategoria_model.dart';
import '../models/categoria_model.dart';
import '../models/pietanza_model.dart';

class MenuProvider with ChangeNotifier {
  final MenuRepository _menuRepository;
  
  List<Macrocategoria> _macrocategorie = [];
  List<Categoria> _categorie = [];
  List<Pietanza> _pietanze = [];
  bool _isLoading = true;
  String? _error;

  MenuProvider(this._menuRepository) {
    _initializeData();
  }

  List<Macrocategoria> get macrocategorie => List.from(_macrocategorie);
  List<Categoria> get categorie => List.from(_categorie);
  List<Pietanza> get pietanze => List.from(_pietanze);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initializeData() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _menuRepository.getMacrocategorieStream().listen((macrocategorie) {
      _macrocategorie = macrocategorie;
      _updateCombinedData();
    }, onError: (error) {
      _error = 'Errore nel caricamento macrocategorie: $error';
      _isLoading = false;
      notifyListeners();
    });

    _menuRepository.getCategorieStream().listen((categorie) {
      _categorie = categorie;
      _updateCombinedData();
    }, onError: (error) {
      _error = 'Errore nel caricamento categorie: $error';
      _isLoading = false;
      notifyListeners();
    });

    _menuRepository.getPietanzeStream().listen((pietanze) {
      _pietanze = pietanze;
      _updateCombinedData();
    }, onError: (error) {
      _error = 'Errore nel caricamento pietanze: $error';
      _isLoading = false;
      notifyListeners();
    });
  }

  void _updateCombinedData() {
    _categorie = _categorie.map((categoria) {
      final pietanzeCategoria = _pietanze.where((p) => p.categoriaId == categoria.id).toList();
      return categoria.copyWith(pietanze: pietanzeCategoria);
    }).toList();

    _macrocategorie = _macrocategorie.map((macrocategoria) {
      final categorieMacro = _categorie.where((c) => c.macrocategoriaId == macrocategoria.id).toList();
      return macrocategoria.copyWith(categorieIds: categorieMacro.map((c) => c.id).toList());
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> aggiungiMacrocategoria(Macrocategoria macrocategoria) async {
    try {
      await _menuRepository.aggiungiMacrocategoria(macrocategoria);
    } catch (e) {
      _error = 'Errore nell\'aggiunta macrocategoria: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modificaMacrocategoria(String id, Macrocategoria macrocategoriaAggiornata) async {
    try {
      await _menuRepository.modificaMacrocategoria(id, macrocategoriaAggiornata);
    } catch (e) {
      _error = 'Errore nella modifica macrocategoria: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminaMacrocategoria(String id) async {
    try {
      final categorieDaEliminare = _categorie.where((c) => c.macrocategoriaId == id).toList();
      for (final categoria in categorieDaEliminare) {
        await eliminaCategoria(categoria.id);
      }
      await _menuRepository.eliminaMacrocategoria(id);
    } catch (e) {
      _error = 'Errore nell\'eliminazione macrocategoria: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> riordinaMacrocategorie(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Macrocategoria item = _macrocategorie.removeAt(oldIndex);
    _macrocategorie.insert(newIndex, item);
    
    final macrocategorieAggiornate = <Macrocategoria>[];
    for (int i = 0; i < _macrocategorie.length; i++) {
      macrocategorieAggiornate.add(_macrocategorie[i].copyWith(ordine: i));
    }
    
    try {
      await _menuRepository.riordinaMacrocategorie(macrocategorieAggiornate);
    } catch (e) {
      _error = 'Errore nel riordino macrocategorie: $e';
      notifyListeners();
      rethrow;
    }
  }

  Macrocategoria? getMacrocategoriaById(String id) {
    try {
      return _macrocategorie.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> aggiungiCategoria(Categoria categoria) async {
    try {
      await _menuRepository.aggiungiCategoria(categoria);
    } catch (e) {
      _error = 'Errore nell\'aggiunta categoria: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modificaCategoria(String id, Categoria categoriaAggiornata) async {
    try {
      await _menuRepository.modificaCategoria(id, categoriaAggiornata);
    } catch (e) {
      _error = 'Errore nella modifica categoria: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminaCategoria(String id) async {
    try {
      final pietanzeDaEliminare = _pietanze.where((p) => p.categoriaId == id).toList();
      for (final pietanza in pietanzeDaEliminare) {
        await eliminaPietanza(pietanza.id);
      }
      await _menuRepository.eliminaCategoria(id);
    } catch (e) {
      _error = 'Errore nell\'eliminazione categoria: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> riordinaCategorie(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Categoria item = _categorie.removeAt(oldIndex);
    _categorie.insert(newIndex, item);
    
    final categorieAggiornate = <Categoria>[];
    for (int i = 0; i < _categorie.length; i++) {
      categorieAggiornate.add(_categorie[i].copyWith(ordine: i));
    }
    
    try {
      await _menuRepository.riordinaCategorie(categorieAggiornate);
    } catch (e) {
      _error = 'Errore nel riordino categorie: $e';
      notifyListeners();
      rethrow;
    }
  }

  Categoria? getCategoriaById(String id) {
    try {
      return _categorie.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Categoria> getCategorieByMacrocategoria(String macrocategoriaId) {
    return _categorie.where((c) => c.macrocategoriaId == macrocategoriaId).toList();
  }

  Future<void> aggiungiPietanza(Pietanza pietanza) async {
    try {
      await _menuRepository.aggiungiPietanza(pietanza);
    } catch (e) {
      _error = 'Errore nell\'aggiunta pietanza: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modificaPietanza(String id, Pietanza pietanzaAggiornata) async {
    try {
      await _menuRepository.modificaPietanza(id, pietanzaAggiornata);
    } catch (e) {
      _error = 'Errore nella modifica pietanza: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminaPietanza(String id) async {
    try {
      await _menuRepository.eliminaPietanza(id);
    } catch (e) {
      _error = 'Errore nell\'eliminazione pietanza: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> aggiornaDisponibilitaPietanza(String id, bool disponibile) async {
    try {
      await _menuRepository.aggiornaDisponibilitaPietanza(id, disponibile);
    } catch (e) {
      _error = 'Errore nell\'aggiornamento disponibilità: $e';
      notifyListeners();
      rethrow;
    }
  }

  Pietanza? getPietanzaById(String id) {
    try {
      return _pietanze.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Pietanza> getPietanzeByCategoria(String categoriaId) {
    return _pietanze.where((p) => p.categoriaId == categoriaId).toList();
  }

  List<Pietanza> getPietanzeByMacrocategoria(String macrocategoriaId) {
    return _pietanze.where((p) => p.macrocategoriaId == macrocategoriaId).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> caricaDatiDemo() async {
    try {
      await _menuRepository.caricaDatiIniziali();
    } catch (e) {
      _error = 'Errore nel caricamento dati demo: $e';
      notifyListeners();
      rethrow;
    }
  }
}