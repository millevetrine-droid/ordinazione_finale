import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:provider/provider.dart';
import 'home/widgets/bottom_nav_bar.dart';
import 'main_tab_screen.dart';
import 'profile_screen.dart';
import '../state/auth_state.dart';
import '../models/cliente_model.dart'; // 👈 USA IL TUO FILE

class PointsDashboardScreen extends StatelessWidget {
  final String numeroTavolo;

  const PointsDashboardScreen({super.key, required this.numeroTavolo});

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    final isLoggedIn = authState.isLoggedIn;
    final currentUser = authState.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // IMMAGINE DI SFONDO (STESSA DELLA HOME)
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // HEADER CON TAVOLO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacitySafe(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF8B4513).withOpacitySafe(0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.table_restaurant, size: 16, color: Colors.amber),
                            const SizedBox(width: 6),
                            Text(
                              'Tavolo $numeroTavolo',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  if (!isLoggedIn) 
                    _buildNotLoggedInView(context)
                  else
                    _buildPointsDashboard(currentUser!),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTabTapped: (index) {
          // 0: Home, 1: Offerte, 2: Ordina, 3: Miei Punti, 4: Altro
          if (index == 0 || index == 1) {
            // Torna alla Home mantenendo lo stack pulito
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }
          if (index == 2) {
            // Vai al flusso di ordinazione (richiede numero tavolo)
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainTabScreen(numeroTavolo: numeroTavolo),
              ),
            );
            return;
          }
          if (index == 3) {
            // Già su Punti
            return;
          }
          if (index == 4) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileScreen(numeroTavolo: numeroTavolo),
              ),
            );
            return;
          }
        },
      ),
    );
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return Expanded(
      child: Center(
          child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacitySafe(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacitySafe(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.loyalty, size: 60, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                'Accumula Punti Fedeltà',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Registrati o accedi per accumulare punti con ogni ordine!\n\nOgni €1 speso = 1 punto',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usa il flusso ordine per accedere')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('ACCUMULA PUNTI CON IL PROSSIMO ORDINE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsDashboard(Cliente user) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // CARD PUNTI PRINCIPALE
            Container(
              padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                color: Colors.black.withOpacitySafe(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacitySafe(0.6),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    '${user.punti} PUNTI',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Punti Fedeltà Accumulati',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // PROSSIMI PREMI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
            color: Colors.black.withOpacitySafe(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.amber.withOpacitySafe(0.6),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎁 I Tuoi Prossimi Premi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildPrizeItem('50 punti', 'Drink in omaggio', user.punti >= 50),
                  _buildPrizeItem('100 punti', 'Antipasto gratis', user.punti >= 100),
                  _buildPrizeItem('200 punti', 'Pizza omaggio', user.punti >= 200),
                  _buildPrizeItem('500 punti', 'Cena per 2 persone', user.punti >= 500),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // COME FUNZIONA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                color: Colors.black.withOpacitySafe(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacitySafe(0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ Come Funziona',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• 1 punto ogni €1 speso\n• I punti si accumulano automaticamente\n• Usa i punti per sbloccare premi esclusivi\n• I premi sono riscattabili al prossimo ordine',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeItem(String punti, String premio, bool sbloccato) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
        color: sbloccato ? Colors.green.withOpacitySafe(0.2) : Colors.grey.withOpacitySafe(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: sbloccato ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            sbloccato ? Icons.check_circle : Icons.lock,
            color: sbloccato ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punti,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: sbloccato ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  premio,
                  style: TextStyle(
                    fontSize: 14,
                    color: sbloccato ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (sbloccato)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SBLOCCATO',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}