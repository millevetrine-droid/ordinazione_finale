import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart' as fb_core;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'presentation/pages/menu_screen.dart';
import 'presentation/pages/login_screen.dart';
import 'presentation/pages/qr_scanner_page.dart';
import 'presentation/pages/cucina/cucina_screen.dart';
import 'presentation/pages/sala/sala_screen.dart';
import 'presentation/pages/proprietario_screen.dart';
import 'presentation/pages/staff_screen.dart'; // ✅ AGGIUNTO
import 'presentation/pages/archivio_screen.dart';
import 'presentation/pages/statistiche_screen.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/menu_provider.dart';
import 'core/providers/ordini_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/session_provider.dart';
import 'package:ordinazione/core/repositories/menu_repository.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('ENTRYPOINT: lib_new main() starting at ${DateTime.now().toIso8601String()}');
  
  // Only initialize Firebase here if it hasn't already been initialized by
  // the delegating entrypoint. This avoids races and double-initialization
  // when the app is launched via the `lib/main.dart` delegator.
  try {
    if (fb_core.Firebase.apps.isEmpty) {
      await fb_core.Firebase.initializeApp();
      debugPrint("✅ Firebase inizializzato con successo (lib_new main)!");
    } else {
      debugPrint("⚠️ Firebase already initialized (lib_new main), skipping init.");
    }
  } catch (e) {
    debugPrint("❌ Errore inizializzazione Firebase (lib_new main): $e");
  }
  // In debug mode, connect to local Firebase emulators if available.
  if (kDebugMode) {
    try {
      // Android emulator: try connecting to local Firestore emulator on a few
      // common ports. We log details so we can diagnose connection issues.
      const host = '10.0.2.2';
      final candidatePorts = [8080, 8085, 8081];
      bool connected = false;
      for (final port in candidatePorts) {
        try {
          FirebaseFirestore.instance.useFirestoreEmulator(host, port);
          // Read back settings if available to confirm
          final settings = FirebaseFirestore.instance.settings;
          debugPrint('🔌 Attempted Firestore emulator hookup at $host:$port — settings.host=${settings.host}, sslEnabled=${settings.sslEnabled}');
          connected = true;
          debugPrint('✅ Connected to Firestore emulator at $host:$port');
          break;
        } catch (e) {
          debugPrint('⚠️ Could not connect to Firestore emulator at $host:$port — $e');
        }
      }
      if (!connected) {
        debugPrint('⚠️ Could not connect to any Firestore emulator candidate ports: $candidatePorts');
      }
    } catch (e) {
      debugPrint('⚠️ Could not connect to Firestore emulator: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MenuRepository>(create: (_) => MenuRepository()),
        ChangeNotifierProvider<MenuProvider>(
          create: (context) => MenuProvider(context.read<MenuRepository>()),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<OrdiniProvider>(create: (_) => OrdiniProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<SessionProvider>(create: (_) => SessionProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Ristorante Mille Vetrine',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.orange,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/menu': (context) => const MenuScreen(),
          '/login': (context) => const LoginScreen(),
          '/qr_scanner': (context) => const QRScannerPage(),
          '/cucina': (context) => const CucinaScreen(),
          '/sala': (context) => const SalaScreen(),
          '/proprietario': (context) => const ProprietarioScreen(),
          '/staff': (context) => const StaffScreen(), // ✅ AGGIUNTO
          '/archivio': (context) => const ArchivioScreen(),
          '/statistiche': (context) => const StatisticheScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}