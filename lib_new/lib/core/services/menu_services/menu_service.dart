import '../../models/categoria_model.dart';
import '../../models/pietanza_model.dart';

class MenuService {
  List<Categoria> getMenuCompleto() {
    return [
      Categoria(
        id: '1',
        macrocategoriaId: '1',
        nome: 'Antipasti',
        emoji: '🍴',
        pietanze: [
          Pietanza(
            id: '1',
            nome: 'Bruschette Miste',
            descrizione: 'Pane tostato con pomodoro, olive e funghi',
            prezzo: 8.50,
            emoji: '🍅',
            ingredienti: ['Pane', 'Pomodoro', 'Olive', 'Funghi', 'Olio'],
            macrocategoriaId: '1', // ✅ AGGIUNTO
          ),
          Pietanza(
            id: '2',
            nome: 'Antipasto della Casa',
            descrizione: 'Selezione di salumi e formaggi locali',
            prezzo: 12.00,
            emoji: '🧀',
            ingredienti: ['Prosciutto', 'Salame', 'Formaggi', 'Olive'],
            macrocategoriaId: '1', // ✅ AGGIUNTO
          ),
        ],
      ),
      Categoria(
        id: '2',
        macrocategoriaId: '2',
        nome: 'Primi Piatti',
        emoji: '🍝',
        pietanze: [
          Pietanza(
            id: '3',
            nome: 'Spaghetti Carbonara',
            descrizione: 'Pasta con uova, guanciale e pecorino',
            prezzo: 11.00,
            emoji: '🍝',
            ingredienti: ['Spaghetti', 'Uova', 'Guanciale', 'Pecorino'],
            macrocategoriaId: '2', // ✅ AGGIUNTO
          ),
          Pietanza(
            id: '4',
            nome: 'Risotto ai Funghi',
            descrizione: 'Risotto cremoso con funghi porcini',
            prezzo: 13.50,
            emoji: '🍄',
            ingredienti: ['Riso', 'Funghi Porcini', 'Brodo', 'Parmigiano'],
            macrocategoriaId: '2', // ✅ AGGIUNTO
          ),
        ],
      ),
      Categoria(
        id: '3',
        macrocategoriaId: '3',
        nome: 'Secondi Piatti',
        emoji: '🍖',
        pietanze: [
          Pietanza(
            id: '5',
            nome: 'Bistecca alla Griglia',
            descrizione: 'Tagliata di manzo con rosmarino',
            prezzo: 18.00,
            emoji: '🥩',
            ingredienti: ['Manzo', 'Rosmarino', 'Olio', 'Sale'],
            macrocategoriaId: '3', // ✅ AGGIUNTO
          ),
          Pietanza(
            id: '6',
            nome: 'Branzino al Sale',
            descrizione: 'Pesce fresco cotto nel sale marino',
            prezzo: 16.50,
            emoji: '🐟',
            ingredienti: ['Branzino', 'Sale Marino', 'Limone', 'Erbe'],
            macrocategoriaId: '3', // ✅ AGGIUNTO
          ),
        ],
      ),
      Categoria(
        id: '4',
        macrocategoriaId: '4',
        nome: 'Dolci',
        emoji: '🍰',
        pietanze: [
          Pietanza(
            id: '7',
            nome: 'Tiramisù',
            descrizione: 'Dolce classico con caffè e mascarpone',
            prezzo: 6.00,
            emoji: '☕',
            ingredienti: ['Mascarpone', 'Caffè', 'Savoiardi', 'Cacao'],
            macrocategoriaId: '4', // ✅ AGGIUNTO
          ),
          Pietanza(
            id: '8',
            nome: 'Panna Cotta',
            descrizione: 'Crema dolce con salsa ai frutti di bosco',
            prezzo: 5.50,
            emoji: '🍓',
            ingredienti: ['Panna', 'Zucchero', 'Vaniglia', 'Frutti di Bosco'],
            macrocategoriaId: '4', // ✅ AGGIUNTO
          ),
        ],
      ),
      Categoria(
        id: '5',
        macrocategoriaId: '5',
        nome: 'Bevande',
        emoji: '🍷',
        pietanze: [
          Pietanza(
            id: '9',
            nome: 'Vino della Casa',
            descrizione: 'Calice di vino rosso o bianco',
            prezzo: 4.00,
            emoji: '🍷',
            ingredienti: ['Vino'],
            macrocategoriaId: '5', // ✅ AGGIUNTO
          ),
          Pietanza(
            id: '10',
            nome: 'Acqua Minerale',
            descrizione: 'Bottiglia da 1L naturale o frizzante',
            prezzo: 2.00,
            emoji: '💧',
            ingredienti: ['Acqua'],
            macrocategoriaId: '5', // ✅ AGGIUNTO
          ),
        ],
      ),
    ];
  }

  // ✅ AGGIUNTO: Metodi stub per risolvere errori di compilazione
  List<Categoria> getCategorieByMacrocategoria({required String macrocategoriaId}) {
    return [];
  }

  List<Pietanza> getPietanzeByCategoria({required String categoriaId, required String macrocategoriaId}) {
    return [];
  }

  List<Pietanza> getPietanzeByMacrocategoria({required String macrocategoriaId}) {
    return [];
  }

  Categoria? getCategoriaById({required String id, required String macrocategoriaId}) {
    return null;
  }

  Pietanza? getPietanzaById({required String id, required String macrocategoriaId}) {
    return null;
  }

  void aggiungiCategoria({required Categoria categoria, required String macrocategoriaId}) {}

  void modificaCategoria({required String id, required Categoria categoria, required String macrocategoriaId}) {}

  void eliminaCategoria({required String id, required String macrocategoriaId}) {}

  void aggiungiPietanza({required Pietanza pietanza, required String macrocategoriaId}) {}

  void modificaPietanza({required String id, required Pietanza pietanza, required String macrocategoriaId}) {}

  void eliminaPietanza({required String id, required String macrocategoriaId}) {}
}