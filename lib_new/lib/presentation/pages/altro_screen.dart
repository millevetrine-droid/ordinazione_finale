import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/auth_provider.dart';
import 'storico_ordini_screen.dart';
import 'login_screen.dart';

class AltroScreen extends StatelessWidget {
  const AltroScreen({super.key});

  void _navigaAStoricoOrdini(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const StoricoOrdiniScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _navigaAStaff(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Content-only widget: to be embedded inside parent Scaffold
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: Colors.black.withAlpha((0.7 * 255).round()),
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),
              title: const Text(
                'I Miei Ordini',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Visualizza lo storico dei tuoi ordini',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
              onTap: () => _navigaAStoricoOrdini(context),
            ),
          ),
          const Spacer(),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Card(
                color: Colors.black.withAlpha((0.7 * 255).round()),
                child: ListTile(
                  leading: const Icon(Icons.people, color: Colors.green),
                  title: const Text(
                    'Area Staff',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Accesso area riservata al personale',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                  onTap: () => _navigaAStaff(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}