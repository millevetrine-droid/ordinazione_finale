import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/presentation/pages/menu_screen.dart';
import 'package:ordinazione/core/providers/menu_provider.dart';
import 'package:ordinazione/core/repositories/menu_repository.dart';

void main() {
  testWidgets('MenuScreen shows categories from provider', (WidgetTester tester) async {
    final repo = MenuRepository();
    final provider = MenuProvider(repo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<MenuRepository>(create: (_) => repo),
          ChangeNotifierProvider<MenuProvider>(create: (_) => provider),
        ],
        child: const MaterialApp(home: MenuScreen()),
      ),
    );

    // initial frame triggers load, show CircularProgressIndicator
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // wait for async load (50ms + pumps)
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ListTile), findsNWidgets(provider.macrocategorie.length));
    expect(find.text('Antipasti'), findsOneWidget);
  });
}
