import 'package:flutter_test/flutter_test.dart';

import 'package:ordinazione/adapters/pietanza_adapter.dart';
import 'package:ordinazione/adapters/ordine_adapter.dart';
import 'package:ordinazione/adapters/categoria_adapter.dart';

void main() {
  test('PietanzaAdapter maps basic map to Pietanza', () {
    final map = {
      'id': 'p1',
      'nome': 'Pizza Margherita',
      'prezzo': 7.5,
      'descrizione': 'Buona',
      'imageUrl': 'http://img',
      'ordine': 2,
      'allergeni': ['glutine', 'lattosio'],
    };

    final p = PietanzaAdapter.fromNewMap(map);
    expect(p.id, 'p1');
    expect(p.nome, 'Pizza Margherita');
    expect(p.prezzo, 7.5);
    expect(p.fotoUrl, 'http://img');
    expect(p.allergeni, isNotNull);
  });

  test('CategoriaAdapter maps map to Categoria', () {
    final map = {
      'id': 'c1',
      'nome': 'Antipasti',
      'ordine': 1,
      'immagine': null,
      'idPadre': null,
    };
    final c = CategoriaAdapter.fromNewMap(map);
    expect(c.id, 'c1');
    expect(c.nome, 'Antipasti');
    expect(c.isMacrocategoria, true);
  });

  test('OrdineAdapter maps map to Ordine', () {
    final map = {
      'tavolo': 'T1',
      'numeroPersone': 2,
      'pietanze': [
        {'idPietanza': 'p1', 'nome': 'Pasta', 'prezzo': 6.0, 'quantita': 2, 'stato': 'in_attesa'}
      ],
      'timestamp': DateTime.now(),
      'accumulaPunti': true,
    };

    final o = OrdineAdapter.fromNewMap('o1', map);
    expect(o.id, 'o1');
    expect(o.tavolo, 'T1');
    expect(o.pietanze.length, 1);
    expect(o.totale, greaterThan(0));
  });
}
