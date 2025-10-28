/// FILE: splash_screen.dart
/// SCOPO: Schermata di inizializzazione app con caricamento Firebase e dati iniziali
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa: 
///   - menu_repository.dart (accesso dati menu)
///   - menu_provider.dart (stato menu)
///   - auth_provider.dart (autenticazione)
///   - session_provider.dart (sessioni)
///   - home_screen.dart (navigazione post-caricamento)
///   - login_screen.dart (navigazione alternativa)
/// - Importato da: main.dart (entry point app)
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Inizializzazione Firebase
/// - Caricamento dati menu iniziali
/// - Barra progresso con stati caricamento
/// - Navigazione automatica a Home dopo caricamento
/// - Gestione errori inizializzazione
/// - Animazioni durante caricamento
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIUNTA barra caricamento 3D preservando tutta la logica esistente
/// - 2024-01-20: MANTENUTA tutta la logica Firebase, navigazione e caricamento dati
/// 
/// DA VERIFICARE:
/// - Firebase si inizializza correttamente
/// - Navigazione a Home funziona
/// - Progress bar aggiornata correttamente
library;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '../../core/repositories/menu_repository.dart';
import '../../core/providers/menu_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/session_provider.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // === STATO CARICAMENTO ===
  bool _initialized = false;
  String _status = 'Inizializzazione...';
  double _progress = 0.1; // 10%
  late AnimationController _animationController;
  // pulse animation removed (was unused) to satisfy analyzer

  @override
  void initState() {
    super.initState();
    
    // === INIZIALIZZAZIONE ANIMAZIONI ===
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // previously used pulse animation removed; controller retained for possible future use
    
    _animationController.repeat(reverse: true);
    debugPrint('Splash (lib_new) initState at ' + DateTime.now().toIso8601String());
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // === METODO: INIZIALIZZAZIONE APP ===
  /// Caricamento completo app: Firebase + Menu + Navigazione
  Future<void> _initializeApp() async {
    // Watchdog: fail-open after timeout so app doesn't stay bloccata sulla splash
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      if (!_initialized) {
        debugPrint('⏱️ Splash timeout: procedo comunque a Home');
        setState(() {
          _status = 'Timeout inizializzazione, procedo...';
          _initialized = true;
          _progress = 1.0;
        });
        _navigateToHome();
      }
    });
    try {
      debugPrint('Splash (lib_new) _initializeApp: start Firebase check at ' + DateTime.now().toIso8601String());
      // FASE 1: Firebase (main.dart dovrebbe aver già inizializzato Firebase)
      setState(() {
        _status = 'Connessione a Firebase...';
        _progress = 0.2;
      });
      try {
        // Evitiamo di reinizializzare se già presente
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        } else {
          debugPrint('Firebase già inizializzato.');
        }
      } catch (e) {
        debugPrint('Errore init Firebase in Splash (non bloccante): $e');
      }
      
      // FASE 2: Menu
      setState(() {
        _status = 'Caricamento menu...';
        _progress = 0.5;
      });
  final menuRepository = MenuRepository();
  final menuProvider = MenuProvider(menuRepository);
  debugPrint('Splash (lib_new): created MenuProvider - starting wait loop at ' + DateTime.now().toIso8601String());
  // Attendi caricamento dati (diagnostic: reduce iterations)
  await _waitForInitialData(menuProvider);
      // Se dopo l'attesa i dati non sono pronti proviamo a caricare i dati demo
      if (menuProvider.isLoading && menuProvider.error == null) {
        debugPrint('Menu non pronto: provo a caricare dati demo di fallback');
        try {
          await menuProvider.caricaDatiDemo();
          // attendi un attimo per permettere agli stream di emettere
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint('Errore caricamento demo fallback: $e');
        }
      }
      
      // FASE 3: Completamento
      setState(() {
        _status = 'Completamento...';
        _progress = 0.9;
      });
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _initialized = true;
        _progress = 1.0;
      });

      // Navigazione automatica
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        _navigateToHome();
      }
      
    } catch (e) {
      // Gestione errori
      setState(() {
        _status = 'Errore: $e';
        _initialized = true;
      });
    }
  }

  // === METODO: ATTESA CARICAMENTO DATI ===
  /// Attende il caricamento iniziale dei dati menu
  Future<void> _waitForInitialData(MenuProvider menuProvider) async {
    int attempts = 0;
    while (attempts < 10) {
      if (!menuProvider.isLoading || menuProvider.error != null) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
  }

  // === METODO: NAVIGAZIONE HOME ===
  /// Naviga alla schermata principale con tutti i provider
  void _navigateToHome() {
    final menuRepository = MenuRepository();
    final menuProvider = MenuProvider(menuRepository);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            Provider<MenuRepository>(create: (_) => menuRepository),
            ChangeNotifierProvider<MenuProvider>(create: (_) => menuProvider),
            ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
            ChangeNotifierProvider<SessionProvider>(create: (_) => SessionProvider()),
          ],
          child: const HomeScreen(),
        ),
      ),
    );
  }

  // _navigateToStaffLogin intentionally removed (unused). Keep navigation logic in _navigateToHome if needed.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withAlpha((0.6 * 255).round()),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // === LOGO E TITOLO ===
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.7 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 80,
                        color: _initialized ? Colors.green : const Color(0xFFFF6B8B),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'RISTORANTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'MILLE VETRINE',
                        style: TextStyle(
                          color: Color(0xFFFF6B8B),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                
                // === BARRA CARICAMENTO 3D ===
                _build3DProgressBar(),
                
                const SizedBox(height: 20),
                Text(
                  _status,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === WIDGET: BARRA PROGRESSO 3D ===
  /// Barra di caricamento con effetto tridimensionale
  /// PRESERVA: tutta la logica progresso esistente
  /// MIGLIORA: solo l'aspetto visivo con effetto 3D
  Widget _build3DProgressBar() {
    return Column(
      children: [
        // Container principale
        Container(
          width: 280,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // Effetto 3D con ombre
              boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.8 * 255).round()),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: Colors.white.withAlpha((0.1 * 255).round()),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[800]!,
                Colors.grey[900]!,
                Colors.black,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Progresso fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 280 * _progress,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF6B8B),
                      const Color(0xFFFF8E53),
                      const Color(0xFFFF6B8B).withAlpha((0.8 * 255).round()),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B8B).withAlpha((0.6 * 255).round()),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              
              // Testo percentuale centrato
              Center(
                child: Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          blurRadius: 4,
                          color: Colors.black.withAlpha((0.5 * 255).round()),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}