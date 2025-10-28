import 'package:ordinazione/models/pietanza_model.dart';
import 'package:ordinazione/models/categoria_model.dart';
import 'menu_cache_service.dart';

class MenuTestDataService {
  void caricaDatiDiTest(MenuCacheService cache) {
    final categorieMenu = _creaCategorieDiTest();
    final pietanzeMenu = _creaPietanzeDiTest();
    final offerteMenu = _creaOfferteDiTest();

    cache.aggiornaDati(
      pietanze: pietanzeMenu,
      categorie: categorieMenu,
      offerte: offerteMenu,
    );
  }

  List<Categoria> _creaCategorieDiTest() {
    return [
      Categoria(id: 'macro1', nome: 'ANTIPASTI', ordine: 1, emoji: '🥗', tipo: 'macrocategoria'),
      Categoria(id: 'macro2', nome: 'PRIMI PIATTI', ordine: 2, emoji: '🍝', tipo: 'macrocategoria'),
      Categoria(id: 'macro3', nome: 'SECONDI PIATTI', ordine: 3, emoji: '🥩', tipo: 'macrocategoria'),
      Categoria(id: 'macro4', nome: 'PIZZE', ordine: 4, emoji: '🍕', tipo: 'macrocategoria'),
      Categoria(id: 'macro5', nome: 'BEVANDE', ordine: 5, emoji: '🥤', tipo: 'macrocategoria'),
      Categoria(id: 'sotto1', nome: 'PIZZE ROSSE', ordine: 1, emoji: '🍅', tipo: 'sottocategoria', idPadre: 'macro4'),
      Categoria(id: 'sotto2', nome: 'PIZZE BIANCHE', ordine: 2, emoji: '🧀', tipo: 'sottocategoria', idPadre: 'macro4'),
      Categoria(id: 'sotto3', nome: 'BIRRE', ordine: 1, emoji: '🍺', tipo: 'sottocategoria', idPadre: 'macro5'),
      Categoria(id: 'sotto4', nome: 'VINI', ordine: 2, emoji: '🍷', tipo: 'sottocategoria', idPadre: 'macro5'),
    ];
  }

  List<Pietanza> _creaPietanzeDiTest() {
    return [
      Pietanza(id: '1', nome: 'Bruschetta al Pomodoro', prezzo: 6.00, descrizione: 'Pane tostato con pomodoro fresco e basilico', emoji: '🍅', categoriaId: 'macro1', macrocategoriaId: 'macro1', ordine: 1),
      Pietanza(id: '2', nome: 'Antipasto della Casa', prezzo: 12.00, descrizione: 'Selezione di salumi e formaggi locali', emoji: '🧀', categoriaId: 'macro1', macrocategoriaId: 'macro1', ordine: 2),
      Pietanza(id: '3', nome: 'Spaghetti Carbonara', prezzo: 12.00, descrizione: 'Spaghetti, uova, guanciale, pecorino', emoji: '🍝', categoriaId: 'macro2', macrocategoriaId: 'macro2', ordine: 1),
      Pietanza(id: '4', nome: 'Risotto ai Funghi', prezzo: 14.00, descrizione: 'Risotto con funghi porcini freschi', emoji: '🍄', categoriaId: 'macro2', macrocategoriaId: 'macro2', ordine: 2),
      Pietanza(id: '5', nome: 'Margherita', prezzo: 8.50, descrizione: 'Pomodoro, mozzarella, basilico fresco', emoji: '🍕', categoriaId: 'sotto1', macrocategoriaId: 'macro4', ordine: 1),
      Pietanza(id: '6', nome: 'Diavola', prezzo: 10.00, descrizione: 'Pomodoro, mozzarella, salame piccante', emoji: '🌶️', categoriaId: 'sotto1', macrocategoriaId: 'macro4', ordine: 2),
      Pietanza(id: '7', nome: 'Quattro Formaggi', prezzo: 11.00, descrizione: 'Mozzarella, gorgonzola, parmigiano, fontina', emoji: '🧀', categoriaId: 'sotto2', macrocategoriaId: 'macro4', ordine: 1),
      Pietanza(id: '8', nome: 'Birra Moretti', prezzo: 4.50, descrizione: 'Birra bionda 33cl', emoji: '🍺', categoriaId: 'sotto3', macrocategoriaId: 'macro5', ordine: 1),
      Pietanza(id: '9', nome: 'Birra Ichnusa', prezzo: 5.00, descrizione: 'Birra sarda 33cl', emoji: '🍺', categoriaId: 'sotto3', macrocategoriaId: 'macro5', ordine: 2),
      Pietanza(id: '10', nome: 'Chianti Classico', prezzo: 18.00, descrizione: 'Vino rosso toscano, bicchiere 0.2L', emoji: '🍷', categoriaId: 'sotto4', macrocategoriaId: 'macro5', ordine: 1),
    ];
  }

  List<Map<String, dynamic>> _creaOfferteDiTest() {
    return [
      {
        'id': '1', 'titolo': '🍔 MENU DEL GIORNO', 'sottotitolo': 'Panino + Patatine + Bibita', 'prezzo': 12.90,
        'immagine': '🍔', 'colore': '#ffff6b8b', 'linkTipo': 'pietanza', 'linkDestinazione': 'menu_giorno_speciale',
        'attiva': true, 'ordine': 1,
      },
      {
        'id': '2', 'titolo': '🎉 OFFERTA SPECIALE', 'sottotitolo': '2 Pizza Margherita + 1 Bibita', 'prezzo': 18.50,
        'immagine': '🍕', 'colore': '#ff4cd964', 'linkTipo': 'categoria', 'linkDestinazione': 'pizze',
        'attiva': true, 'ordine': 2,
      },
      {
        'id': '3', 'titolo': '☕ COLAZIONE ITALIANA', 'sottotitolo': 'Cappuccino + Cornetto', 'prezzo': 4.50,
        'immagine': '☕', 'colore': '#ff5ac8fa', 'linkTipo': 'pietanza', 'linkDestinazione': 'colazione_italiana',
        'attiva': true, 'ordine': 3,
      },
      {
        'id': '4', 'titolo': '🍝 PASTA FRESCA', 'sottotitolo': 'Pasta fatta in casa con sugo speciale', 'prezzo': 11.00,
        'immagine': '🍝', 'colore': '#ffffd700', 'linkTipo': 'categoria', 'linkDestinazione': 'paste',
        'attiva': true, 'ordine': 4,
      },
    ];
  }
}
