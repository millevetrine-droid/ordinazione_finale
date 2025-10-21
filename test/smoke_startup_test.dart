import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:ordinazione/main.dart' as app;

void main() {
  testWidgets('app starts and builds', (WidgetTester tester) async {
    // Ensure binding initialized
    TestWidgetsFlutterBinding.ensureInitialized();

  // Pump the app's MyApp widget directly so the test harness controls the tree
  await tester.pumpWidget(const app.MyApp());

  // Let the app settle
  await tester.pumpAndSettle(const Duration(seconds: 2));

    // Sanity check: the app should have a MaterialApp in the widget tree
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
