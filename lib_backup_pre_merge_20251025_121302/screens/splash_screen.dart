import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'dart:developer' as dev;
import 'home/home_screen.dart';
import '../services/firebase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  String _status = 'Inizializzazione...';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    dev.log('Splash (lib) initState at ' + DateTime.now().toIso8601String(), name: 'Splash');
    _initializeApp();
    // Hard watchdog: forza la navigazione in Home dopo 2s in ogni caso
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_navigated) return;
      dev.log('⏱️ Watchdog splash (lib): forzo navigazione a Home', name: 'Splash');
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    });
  }

  void _initializeApp() async {
    try {
      setState(() {
        _progress = 0.1;
        _status = 'Preparazione...';
      });

  // 👇 OTTIMIZZATO: Caricamento parallelo e non bloccante
  dev.log('Splash (lib) _initializeApp: starting menu load at ' + DateTime.now().toIso8601String(), name: 'Splash');
  final menuFuture = FirebaseService.menu.inizializzaMenu();
      
      // 👇 Progresso simulato per esperienza utente fluida
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _progress = 0.4;
        _status = 'Caricamento interfaccia...';
      });

      // 👇 ASPETTIAMO AL MASSIMO 1.2 secondi per il menu (diagnostic)
      await Future.wait([
        menuFuture.timeout(const Duration(milliseconds: 1200), onTimeout: () {
          dev.log('⚠️ Timeout caricamento menu - Continua comunque', name: 'SplashScreen');
          return null; // 👈 Non blocchiamo se lento
        }),
        Future.delayed(const Duration(milliseconds: 600)), // Animazione fluida
      ]);

      setState(() {
        _progress = 0.8;
        _status = 'Quasi pronto...';
      });

      // 👇 Ultimo ritardo per smooth transition
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _progress = 1.0;
        _status = 'Completato!';
      });

      // 👇 Vai alla home IMMEDIATAMENTE dopo breve pausa
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted && !_navigated) {
        // Ensure navigation happens after the first frame to avoid calling
        // Navigator during the build phase (helps widget tests and avoids
        // `setState() or markNeedsBuild() called during build` exceptions).
        _navigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      }

    } catch (e) {
      dev.log('❌ Errore inizializzazione: $e', name: 'SplashScreen');
      // 👇 FALLBACK RAPIDO: vai alla home comunque
      if (mounted && !_navigated) {
        _navigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // IMMAGINE DI SFONDO
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFFF6B8B),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // OVERLAY CON BARRA DI CARICAMENTO
          Positioned(
            bottom: 100,
            left: 40,
            right: 40,
            child: Container(
              padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                color: Colors.black.withOpacitySafe(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // BARRA DI PROGRESSO
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B8B),
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // PERCENTUALE E STATO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}