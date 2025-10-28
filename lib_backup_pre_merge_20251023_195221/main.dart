import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import the newer app implementation and run it from this legacy entrypoint.
// We use a relative import because `lib_new` is outside the package `lib/` folder.
import 'file:///C:/Users/Anselmo/Documents/ordinazione/lib_new/lib/main.dart' as new_app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dev.log('ENTRYPOINT: delegating to lib_new MyApp at ' + DateTime.now().toIso8601String(), name: 'main');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    dev.log('✅ Firebase initialized (legacy delegator)', name: 'main');
  } catch (e) {
    dev.log('❌ Firebase init error (legacy delegator): $e', name: 'main');
    // proceed even if Firebase fails
  }

  // Run the newer application implementation so the runtime is the `lib_new` app.
  runApp(const new_app.MyApp());
}

// Backwards-compatible wrapper so callers that import `package:ordinazione/main.dart`
// and expect a `MyApp` class still work (tests reference `app.MyApp`).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const new_app.MyApp();
  }
}