import '../../models/pietanza_model.dart';
import '../../models/categoria_model.dart';
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
      Categoria(id: 'macro1', nome: 'ANTIPASTI', ordine: 1, imageUrl: '🥗', tipo: 'macrocategoria', pietanze: [] , macrocategoriaId: 'macro1'),
      Categoria(id: 'macro2', nome: 'PRIMI PIATTI', ordine: 2, imageUrl: '🍝', tipo: 'macrocategoria', pietanze: [], macrocategoriaId: 'macro2'),
      Categoria(id: 'macro3', nome: 'SECONDI PIATTI', ordine: 3, imageUrl: '🥩', tipo: 'macrocategoria', pietanze: [], macrocategoriaId: 'macro3'),
      Categoria(id: 'macro4', nome: 'PIZZE', ordine: 4, imageUrl: '🍕', tipo: 'macrocategoria', pietanze: [], macrocategoriaId: 'macro4'),
      Categoria(id: 'macro5', nome: 'BEVANDE', ordine: 5, imageUrl: '🥤', tipo: 'macrocategoria', pietanze: [], macrocategoriaId: 'macro5'),
      Categoria(id: 'sotto1', nome: 'PIZZE ROSSE', ordine: 1, imageUrl: '🍅', tipo: 'sottocategoria', idPadre: 'macro4', pietanze: [], macrocategoriaId: 'macro4'),
      Categoria(id: 'sotto2', nome: 'PIZZE BIANCHE', ordine: 2, imageUrl: '🧀', tipo: 'sottocategoria', idPadre: 'macro4', pietanze: [], macrocategoriaId: 'macro4'),
      Categoria(id: 'sotto3', nome: 'BIRRE', ordine: 1, imageUrl: '🍺', tipo: 'sottocategoria', idPadre: 'macro5', pietanze: [], macrocategoriaId: 'macro5'),
      Categoria(id: 'sotto4', nome: 'VINI', ordine: 2, imageUrl: '🍷', tipo: 'sottocategoria', idPadre: 'macro5', pietanze: [], macrocategoriaId: 'macro5'),
    ];
  }

  List<Pietanza> _creaPietanzeDiTest() {
    return [
      Pietanza(id: '1', nome: 'Bruschetta al Pomodoro', prezzo: 6.00, categoriaId: 'macro1', descrizione: 'Pane tostato con pomodoro fresco e basilico', imageUrl: '🍅', macrocategoriaId: 'macro1'),
      Pietanza(id: '2', nome: 'Antipasto della Casa', prezzo: 12.00, categoriaId: 'macro1', descrizione: 'Selezione di salumi e formaggi locali', imageUrl: '🧀', macrocategoriaId: 'macro1'),
      Pietanza(id: '3', nome: 'Spaghetti Carbonara', prezzo: 12.00, categoriaId: 'macro2', descrizione: 'Spaghetti, uova, guanciale, pecorino', imageUrl: '🍝', macrocategoriaId: 'macro2'),
      Pietanza(id: '4', nome: 'Risotto ai Funghi', prezzo: 14.00, categoriaId: 'macro2', descrizione: 'Risotto con funghi porcini freschi', imageUrl: '🍄', macrocategoriaId: 'macro2'),
      Pietanza(id: '5', nome: 'Margherita', prezzo: 8.50, categoriaId: 'sotto1', descrizione: 'Pomodoro, mozzarella, basilico fresco', imageUrl: '🍕', macrocategoriaId: 'macro4'),
      Pietanza(id: '6', nome: 'Diavola', prezzo: 10.00, categoriaId: 'sotto1', descrizione: 'Pomodoro, mozzarella, salame piccante', imageUrl: '🌶️', macrocategoriaId: 'macro4'),
      Pietanza(id: '7', nome: 'Quattro Formaggi', prezzo: 11.00, categoriaId: 'sotto2', descrizione: 'Mozzarella, gorgonzola, parmigiano, fontina', imageUrl: '🧀', macrocategoriaId: 'macro4'),
      Pietanza(id: '8', nome: 'Birra Moretti', prezzo: 4.50, categoriaId: 'sotto3', descrizione: 'Birra bionda 33cl', imageUrl: '🍺', macrocategoriaId: 'macro5'),
      Pietanza(id: '9', nome: 'Birra Ichnusa', prezzo: 5.00, categoriaId: 'sotto3', descrizione: 'Birra sarda 33cl', imageUrl: '🍺', macrocategoriaId: 'macro5'),
      Pietanza(id: '10', nome: 'Chianti Classico', prezzo: 18.00, categoriaId: 'sotto4', descrizione: 'Vino rosso toscano, bicchiere 0.2L', imageUrl: '🍷', macrocategoriaId: 'macro5'),
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
