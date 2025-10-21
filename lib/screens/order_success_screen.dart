import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:provider/provider.dart';
import 'main_tab_screen.dart';
import '../state/auth_state.dart';

class OrderSuccessScreen extends StatelessWidget {
  final int puntiGuadagnati;
  final int puntiTotali;
  final String numeroTavolo;
  final String? telefonoCliente;

  const OrderSuccessScreen({
    super.key,
    required this.puntiGuadagnati,
    required this.puntiTotali,
    required this.numeroTavolo,
    this.telefonoCliente,
  });

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    final isLoggedIn = authState.isLoggedIn;

    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ICONA SUCCESSO ANIMATA
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacitySafe(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // TITOLO PRINCIPALE
                Text(
                  '🎉 ORDINE CONFERMATO!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 10),
                Text(
                  'Il tuo ordine è in preparazione',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // CARD CON INFORMAZIONI
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // INFORMAZIONE ORDINE
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ordine inviato alla cucina',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // PUNTI GUADAGNATI (se presenti)
                        if (puntiGuadagnati > 0) ...[
                          Row(
                            children: [
                              const Icon(Icons.loyalty, color: Colors.orange, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Punti accumulati',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '+$puntiGuadagnati punti 🎊', // 👈 1 punto per 1 euro
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Hai speso €$puntiGuadagnati', // 👈 Mostra importo speso
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // TOTALE PUNTI
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Totale punti: $puntiTotali',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 10),
                        ],
                        
                        // MESSAGGIO INCORAGGIANTE
                        Text(
                          puntiGuadagnati > 0 
                              ? 'Continua ad accumulare punti per sbloccare premi esclusivi! 🏆'
                              : 'Registrati al prossimo ordine per accumulare punti fedeltà! 💫',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // MESSAGGIO DI NAVIGAZIONE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.navigation, color: Colors.blue, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Usa il menu in basso per navigare',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ordina di nuovo, controlla i tuoi punti o accedi al profilo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // TAB BAR AL POSTO DEI 3 PULSANTI
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacitySafe(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1, // Rimane su "Ordina"
          onTap: (index) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => MainTabScreen(numeroTavolo: numeroTavolo),
              ),
              (route) => false,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF8B4513),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Ordina',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.loyalty_outlined),
              activeIcon: Icon(Icons.loyalty),
              label: 'Punti',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outlined),
              activeIcon: const Icon(Icons.person),
              label: isLoggedIn ? 'Profilo' : 'Accedi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined),
              activeIcon: Icon(Icons.more_horiz),
              label: 'Altro',
            ),
          ],
        ),
      ),
    );
  }
}