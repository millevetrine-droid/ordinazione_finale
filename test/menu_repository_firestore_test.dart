import 'package:flutter_test/flutter_test.dart';
import 'package:ordinazione/core/repositories/menu_repository.dart';

class TestMenuRepository extends MenuRepository {
  final List<Map<String, dynamic>> docs;

  TestMenuRepository({required this.docs});

  @override
  Future<List<Macrocategoria>> fetchMacrocategorie() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return docs
        .asMap()
        .entries
        .map((e) => Macrocategoria(id: '${e.key}', nome: e.value['nome'] as String, ordine: 0))
        .toList(growable: false);
  }
}

void main() {
  test('MenuRepository (fake) returns categorias', () async {
    final fakeDocs = [
      {'nome': 'Antipasti'},
      {'nome': 'Primi'},
    ];
    final repo = TestMenuRepository(docs: fakeDocs);
    final cats = await repo.fetchMacrocategorie();
    expect(cats.length, 2);
    expect(cats[0].nome, 'Antipasti');
  });
}
