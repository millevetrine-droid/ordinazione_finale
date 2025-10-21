import 'package:flutter_test/flutter_test.dart';
import 'package:ordinazione/services/firebase/menu_test_data_service.dart';
import 'package:ordinazione/services/firebase/menu_cache_service.dart';
import 'package:ordinazione/adapters/menu_importer.dart';

void main() {
  test('smoke import lib_new menu into MenuCacheService', () {
    // Use generator to populate a temporary cache, then convert that cache's
    // contents into the raw Maps expected by MenuImporter to simulate the
    // lib_new -> Map flow.
    final seedCache = MenuCacheService();
    final generator = MenuTestDataService();
    generator.caricaDatiDiTest(seedCache);

    final pietanzeRaw = seedCache.pietanzeMenu.map((p) => {
      'id': p.id,
      'nome': p.nome,
      'prezzo': p.prezzo,
      'categoria': p.categoria,
      'categoriaId': p.categoriaId,
      'descrizione': p.descrizione,
      'immagine': p.immagine,
      'ordine': p.ordine,
    }).toList();

    final categorieRaw = seedCache.categorieMenu.map((c) => {
      'id': c.id,
      'nome': c.nome,
      'ordine': c.ordine,
      'immagine': c.immagine,
      'tipo': c.tipo,
      if (c.idPadre != null) 'idPadre': c.idPadre,
    }).toList();

    final offerteRaw = seedCache.offerteMenu.map((o) => Map<String, dynamic>.from(o)).toList();

    final map = {
      'pietanze': pietanzeRaw,
      'categorie': categorieRaw,
      'offerte': offerteRaw,
    };

    final cache = MenuCacheService();
    final importer = MenuImporter(cache);
    importer.importFromNewSource(map);

    expect(cache.pietanzeMenu.length, seedCache.pietanzeMenu.length);
    expect(cache.categorieMenu.length, seedCache.categorieMenu.length);
    expect(cache.offerteMenu.length, seedCache.offerteMenu.length);
  });
}
