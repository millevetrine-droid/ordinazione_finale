import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ordinazione/core/repositories/menu_repository.dart';

void main() {
  test('MenuRepositoryFirestore reads from FakeFirebaseFirestore', () async {
    final fake = FakeFirebaseFirestore();
    // seed fake collection
    await fake.collection('macrocategorie').add({'nome': 'Antipasti'});
    await fake.collection('macrocategorie').add({'nome': 'Primi'});

    final repo = MenuRepositoryFirestore(firestore: fake);
    final cats = await repo.fetchMacrocategorie();

    expect(cats.length, 2);
    expect(cats.any((c) => c.nome == 'Antipasti'), isTrue);
  });
}
