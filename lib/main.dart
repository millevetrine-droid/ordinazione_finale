import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart' as fb_core;
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
import 'core/repositories/menu_repository.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('ENTRYPOINT: lib_new main() starting at ' + DateTime.now().toIso8601String());
  
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