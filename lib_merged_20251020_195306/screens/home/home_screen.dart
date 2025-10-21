import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'dart:developer' as dev;
import 'widgets/home_header.dart';
import 'widgets/offerta_card.dart';
import 'widgets/bottom_nav_bar.dart';
import 'dialogs/cambio_tavolo_dialog.dart';
import '../qr_scanner_screen.dart';
import '../login_screen.dart';
import '../main_tab_screen.dart';
import '../../services/firebase/menu_service.dart';

class HomeScreen extends StatefulWidget {
  final String? deepLinkTavolo;
  final String? deepLinkTipo;
  final String? deepLinkCodice;

  const HomeScreen({
    super.key,
    this.deepLinkTavolo,
    this.deepLinkTipo,
    this.deepLinkCodice,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _currentTavolo;
  List<Map<String, dynamic>> _offerte = [];
  bool _isLoading = true;
  bool _errorCaricamento = false;

  @override
  void initState() {
    super.initState();
    _initializeTavolo();
    _setupDeepLinkListener();
    _caricaOfferte();
  }

  void _caricaOfferte() async {
    try {
      setState(() {
        _isLoading = true;
        _errorCaricamento = false;
      });
      
      // 👇 OTTIMIZZATO: Timeout e cache intelligente
      List<Map<String, dynamic>> offerte;
      try {
        offerte = await MenuService.getOfferteStatic()
            .timeout(const Duration(seconds: 3), onTimeout: () {
          dev.log('⚠️ Timeout caricamento offerte - uso cache locale', name: 'HomeScreen');
          return []; // 👈 Ritorna lista vuota invece di errore
        });
      } catch (e) {
        dev.log('❌ Errore caricamento offerte: $e', name: 'HomeScreen');
        offerte = []; // 👈 Fallback a lista vuota
      }
      
      setState(() {
        _offerte = offerte;
        _isLoading = false;
      });
      
  dev.log('✅ Offerte caricate: ${_offerte.length} offerte', name: 'HomeScreen');
      
    } catch (e) {
      dev.log('❌ Errore critico caricamento offerte: $e', name: 'HomeScreen');
      setState(() {
        _isLoading = false;
        _errorCaricamento = true;
        _offerte = []; // 👈 Mostra comunque l'interfaccia
      });
    }
  }

  void _initializeTavolo() {
    if (widget.deepLinkTavolo != null) {
      _currentTavolo = widget.deepLinkTavolo;
    }
  }

  void _setupDeepLinkListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForTavoloChange();
    });
  }

  void _checkForTavoloChange() {
    if (widget.deepLinkTavolo != null && _currentTavolo != null) {
      if (widget.deepLinkTavolo != _currentTavolo) {
        CambioTavoloDialog.show(
          context: context,
          currentTavolo: _currentTavolo!,
          nuovoTavolo: widget.deepLinkTavolo!,
          onConferma: (nuovoTavolo) => _cambiaTavolo(nuovoTavolo),
        );
      }
    }
  }

  void _cambiaTavolo(String nuovoTavolo) {
    setState(() {
      _currentTavolo = nuovoTavolo;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Ora sei al Tavolo $nuovoTavolo'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onOrdinaOraPressed() {
    if (_currentTavolo != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainTabScreen(numeroTavolo: _currentTavolo!),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const QrScannerScreen(),
        ),
      );
    }
  }

  void _onOffertaTap(Map<String, dynamic> offerta) {
    final linkTipo = offerta['linkTipo'];
    final linkDestinazione = offerta['linkDestinazione'];
    
    switch (linkTipo) {
      case 'pietanza':
        _navigaAPietanza(linkDestinazione);
        break;
      case 'categoria':
        _navigaACategoria(linkDestinazione);
        break;
      case 'url':
        _apriUrlEsterno(linkDestinazione);
        break;
      default:
        _onOrdinaOraPressed();
    }
  }

  void _navigaAPietanza(String idPietanza) {
    _onOrdinaOraPressed();
  }

  void _navigaACategoria(String idCategoria) {
    _onOrdinaOraPressed();
  }

  void _apriUrlEsterno(String url) {
    // Implementa con url_launcher
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      _onOrdinaOraPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF6CC1E6),
                        Color(0xFF4A90E2),
                        Color(0xFF7B68EE),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HomeHeader(
                          currentTavolo: _currentTavolo,
                          onTestPressed: () => _selezionaTavoloTest(context),
                          onStaffPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacitySafe(0.3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                '🎁 OFFERTE SPECIALI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // 👇 SEZIONE OFFERTE OTTIMIZZATA
                              if (_isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              else if (_errorCaricamento)
                                _buildErroreCaricamento()
                              else if (_offerte.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'Nessuna offerta disponibile al momento',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              else
                                ..._offerte.map((offerta) => OffertaCard(
                                  offerta: offerta,
                                  onTap: () => _onOffertaTap(offerta),
                                )),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  // 👇 NUOVO: Widget per gestione errori
  Widget _buildErroreCaricamento() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          const Text(
            'Connessione lenta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Le offerte non sono disponibili',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            onPressed: _caricaOfferte,
            child: const Text('RIPROVA'),
          ),
        ],
      ),
    );
  }

  void _selezionaTavoloTest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎯 Seleziona Tavolo di Prova'),
        content: const Text('Scegli un numero di tavolo per testare l\'app:'),
        actions: [
          Wrap(
            spacing: 10,
            children: [1, 2, 3, 4].map((numero) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainTabScreen(numeroTavolo: numero.toString()),
                    ),
                  );
                },
                child: Text('Tavolo $numero'),
              );
            }).toList(),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }
}