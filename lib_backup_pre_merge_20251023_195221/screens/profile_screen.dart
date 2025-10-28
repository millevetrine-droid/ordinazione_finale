import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../models/cliente_model.dart'; // 👈 USA IL TUO FILE

class ProfileScreen extends StatelessWidget {
  final String numeroTavolo;

  const ProfileScreen({super.key, required this.numeroTavolo});

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
                    _buildProfileView(currentUser!, authState, context),
                ],
              ),
            ),
          ),
        ],
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
              const Icon(Icons.person, size: 60, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                'Il Tuo Profilo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Accedi per visualizzare il tuo profilo, lo storico ordini e gestire le tue preferenze.',
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
                child: const Text('ACCEDI CON IL PROSSIMO ORDINE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(Cliente user, AuthState authState, BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // CARD PROFILO UTENTE
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacitySafe(0.7),
                borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF8B4513).withOpacitySafe(0.6),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF8B4513),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.telefono,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacitySafe(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      '${user.punti} PUNTI',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SEZIONE IMPOSTAZIONI
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚙️ Impostazioni',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildProfileItem(Icons.history, 'Storico Ordini', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Storico ordini - In sviluppo')),
                    );
                  }),
                  _buildProfileItem(Icons.notifications, 'Notifiche', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifiche - In sviluppo')),
                    );
                  }),
                  _buildProfileItem(Icons.privacy_tip, 'Privacy', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy - In sviluppo')),
                    );
                  }),
                  _buildProfileItem(Icons.help, 'Aiuto & Supporto', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aiuto - In sviluppo')),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BOTTONE LOGOUT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  authState.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Arrivederci!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacitySafe(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('LOGOUT'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String text, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF8B4513)),
        title: Text(text, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.transparent,
      ),
    );
  }
}