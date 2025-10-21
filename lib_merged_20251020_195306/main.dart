import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'presentation/pages/menu_screen.dart';
import 'presentation/pages/login_screen.dart';
import 'presentation/pages/qr_scanner_page.dart';
import 'presentation/pages/cucina/cucina_screen.dart';
import 'presentation/pages/sala/sala_screen.dart';
import 'presentation/pages/proprietario_screen.dart';
import 'presentation/pages/staff_screen.dart';
import 'presentation/pages/archivio_screen.dart';
import 'presentation/pages/statistiche_screen.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/menu_provider.dart';
import 'core/providers/ordini_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/session_provider.dart';
import 'core/repositories/menu_repository.dart';

// Optional: support generated firebase_options if present
import 'firebase_options.dart' show DefaultFirebaseOptions;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Try to initialize with generated options; if not available, fallback
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase inizializzato con successo!");
  } catch (e) {
    debugPrint("❌ Errore inizializzazione Firebase con options: $e");
    try {
      await Firebase.initializeApp();
    } catch (e2) {
      debugPrint("❌ Errore inizializzazione Firebase fallback: $e2");
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
          '/staff': (context) => const StaffScreen(),
          '/archivio': (context) => const ArchivioScreen(),
          '/statistiche': (context) => const StatisticheScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}