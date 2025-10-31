import 'package:flutter/foundation.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';

class CartItem {
  final Pietanza pietanza;
  int quantita;

  CartItem({
    required this.pietanza,
    required this.quantita,
  });

  double get subtotale => pietanza.prezzo * quantita;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.from(_items);

  double get totale {
    return _items.fold(0.0, (total, item) => total + item.subtotale);
  }

  int get numeroArticoli {
    return _items.fold(0, (total, item) => total + item.quantita);
  }

  // ✅ NUOVO: Alias per compatibilità
  int get itemCount => numeroArticoli;
  
  // ✅ NUOVO: Alias per compatibilità
  int get totaleElementi => numeroArticoli;

  bool get isEmpty => _items.isEmpty;

  void aggiungiAlCarrello(Pietanza pietanza) {
    final index = _items.indexWhere((item) => item.pietanza.id == pietanza.id);
    
    if (index != -1) {
      _items[index].quantita++;
    } else {
      _items.add(CartItem(pietanza: pietanza, quantita: 1));
    }
    
    notifyListeners();
  }

  void rimuoviDalCarrello(String pietanzaId) { // ✅ CORRETTO: Accetta String ID
    final index = _items.indexWhere((item) => item.pietanza.id == pietanzaId);
    
    if (index != -1) {
      if (_items[index].quantita > 1) {
        _items[index].quantita--;
      } else {
        _items.removeAt(index);
      }
    }
    
    notifyListeners();
  }

  void rimuoviTuttoDalCarrello(String pietanzaId) {
    _items.removeWhere((item) => item.pietanza.id == pietanzaId);
    notifyListeners();
  }

  void svuotaCarrello() {
    _items.clear();
    notifyListeners();
  }

  int getQuantita(String pietanzaId) {
    return _items.firstWhere(
      (item) => item.pietanza.id == pietanzaId,
      orElse: () => CartItem(
        pietanza: Pietanza(
          id: '', 
          nome: '', 
          descrizione: '', 
          prezzo: 0, 
          emoji: '',
          categoriaId: '', // ✅ MODIFICATO: ora opzionale
          macrocategoriaId: 'default', // ✅ AGGIUNTO: parametro richiesto
        ), 
        quantita: 0
      ),
    ).quantita;
  }

  bool contiene(Pietanza pietanza) {
    return _items.any((item) => item.pietanza.id == pietanza.id);
  }
}