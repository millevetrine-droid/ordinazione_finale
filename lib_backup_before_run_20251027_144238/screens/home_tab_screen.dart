import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
// removed duplicate import

class HomeTabScreen extends StatelessWidget {
  final String numeroTavolo;

  const HomeTabScreen({super.key, required this.numeroTavolo});

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    final isLoggedIn = authState.isLoggedIn;
    final currentUser = authState.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // IMMAGINE DI SFONDO (STESSA DELLA HOME ORIGINALE)
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
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
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // CONTENUTO PRINCIPALE
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // HEADER CON TAVOLO E BENVENUTO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TAVOLO CORRENTE
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

                  const SizedBox(height: 20),

                  // SALUTO PERSONALIZZATO
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacitySafe(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacitySafe(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isLoggedIn ? 'Bentornato, ${currentUser!.nome}! 🎉' : 'Benvenuto!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLoggedIn 
                              ? 'Hai ${currentUser!.punti} punti fedeltà'
                              : 'Accumula punti con ogni ordine!',
                          style: TextStyle(
                            fontSize: 16, 
                            color: Colors.grey[300],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CARD ORDINA ORA
                  Card(
                    color: Colors.black.withOpacitySafe(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: const Color(0xFF8B4513).withOpacitySafe(0.6), width: 1),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, color: Color(0xFF8B4513)),
                      title: const Text('Ordina ora', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Sfoglia il menu completo', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF8B4513)),
                      onTap: () {
                        // Cambia al tab "Ordina" (index 1)
                        // Implementeremo la navigazione tra tab
                      },
                    ),
                  ),

                  // Sezione ultimi ordini (se loggato)
                  if (isLoggedIn) ...[
                    const SizedBox(height: 20),
                    const Text('I tuoi ultimi ordini', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.black.withOpacitySafe(0.7),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('Nessun ordine recente', 
                              style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 12),
                            // Qui potremo aggiungere la lista degli ordini
                          ],
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // MESSAGGIO PROMOZIONALE
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513).withOpacitySafe(0.8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_offer, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ordina ora e accumula punti! Ogni €10 = 1 punto',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
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