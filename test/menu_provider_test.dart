import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ordinazione/core/providers/menu_provider.dart';
import 'package:ordinazione/core/repositories/menu_repository.dart';

void main() {
  test('MenuProvider loads macrocategorie', () async {
  final fake = FakeFirebaseFirestore();
  await fake.collection('ristoranti').doc('mille_vetrine').collection('macrocategorie').add({'nome': 'Antipasti'});
  final repo = MenuRepository(firestore: fake);
  final provider = MenuProvider(repo);

  // Give the Firestore stream a moment to emit and the provider to process it
  await Future.delayed(const Duration(milliseconds: 50));

  expect(provider.loading, isFalse);
  expect(provider.macrocategorie, isNotEmpty);
  });
}
