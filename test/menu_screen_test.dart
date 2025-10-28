import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ordinazione/presentation/pages/menu_screen.dart';
import 'package:ordinazione/core/providers/menu_provider.dart';
import 'package:ordinazione/core/repositories/menu_repository.dart';
import 'package:ordinazione/core/providers/cart_provider.dart';

void main() {
  testWidgets('MenuScreen shows categories from provider', (WidgetTester tester) async {
  final fake = FakeFirebaseFirestore();
  // seed demo data under the path MenuRepository expects with explicit IDs
  await fake.collection('ristoranti').doc('mille_vetrine').collection('macrocategorie').doc('m1').set({'nome': 'Antipasti', 'ordine': 0});
  await fake.collection('ristoranti').doc('mille_vetrine').collection('categorie').doc('c1').set({'nome': 'Antipasti generici', 'macrocategoriaId': 'm1', 'ordine': 0});
  await fake.collection('ristoranti').doc('mille_vetrine').collection('pietanze').doc('p1').set({'nome': 'Bruschetta', 'categoriaId': 'c1', 'disponibile': true, 'prezzo': 5.0});
  final repo = MenuRepository(firestore: fake);
  final provider = MenuProvider(repo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<MenuRepository>(create: (_) => repo),
          ChangeNotifierProvider<MenuProvider>(create: (_) => provider),
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ],
  child: const MaterialApp(home: Scaffold(body: MenuScreen())),
      ),
    );

    // let the provider/streams settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // expect the list tiles corresponding to macrocategorie
    expect(find.byType(ListTile), findsNWidgets(provider.macrocategorie.length));
  expect(find.text('ANTIPASTI'), findsOneWidget);
  });
}
