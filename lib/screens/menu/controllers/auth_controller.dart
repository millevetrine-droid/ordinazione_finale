import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/firebase_service.dart';
import '../../../models/cliente_model.dart';
import '../../../state/auth_state.dart';

// Import dei dialog
import '../dialogs/order_confirmation_dialog.dart';
import '../dialogs/registrati_accedi_dialog.dart';
import '../dialogs/login_dialog.dart';
import '../dialogs/registration_dialog.dart';
import '../dialogs/success_error_dialogs.dart';

class AuthController {
  final Map<String, int> _tentativiAccesso = {};
  final Map<String, DateTime> _blocchiTemporanei = {};

  // 👇 METODI PER I DIALOG
  void showOrderConfirmationDialog(
    BuildContext context, 
    double totalPrice, 
    int totalItems, {
    required VoidCallback onNoGrazie,
    required VoidCallback onSiAccumula,
  }) {
    showDialog(
      context: context,
      builder: (context) => OrderConfirmationDialog(
        totalPrice: totalPrice,
        totalItems: totalItems,
        onNoGrazie: onNoGrazie,
        onSiAccumula: onSiAccumula,
      ),
    );
  }

  void showRegistratiAccediDialog(BuildContext context, int puntiGuadagnati) {
    showDialog(
      context: context,
      builder: (context) => RegistratiAccediDialog(
        puntiGuadagnati: puntiGuadagnati,
        onRegistrati: () {
          Navigator.of(context).pop();
          _showRegistrationDialog(context);
        },
        onAccedi: () {
          Navigator.of(context).pop();
          _showLoginDialog(context);
        },
      ),
    );
  }

  void showLoginDialog(BuildContext context) {
    _showLoginDialog(context);
  }

  // Pubblico: mostra il dialogo di registrazione
  void showRegistrationDialog(BuildContext context) {
    _showRegistrationDialog(context);
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LoginDialog(
        onLogin: (phone, password) => _verificaLogin(context, phone, password),
        onRecuperaPassword: () => _recuperaPassword(context),
      ),
    );
  }

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RegistrationDialog(
        onRegistrati: (nome, cognome, telefono, password) {
          Navigator.of(context).pop();
          _registraCliente(context, nome, cognome, telefono, password);
        },
      ),
    );
  }

  void apriProfiloCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔐 Accesso al Profilo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.security, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              'Accedi con telefono e password',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              '💰 Sistema completamente gratuito e sicuro',
              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showLoginDialog(context);
            },
            child: const Text('ACCEDI'),
          ),
        ],
      ),
    );
  }

  // 👇 LOGICA BUSINESS
  void _verificaLogin(BuildContext context, String telefono, String password) async {
    if (_isTelefonoBloccato(telefono)) {
      _mostraMessaggioBlocco(context, telefono);
      return;
    }
    // Capture navigator, scaffold and auth state before awaiting to avoid using
    // BuildContext across async gaps.
    // Capture navigator and auth state before async gaps
    final nav = Navigator.of(context);
    final authState = Provider.of<AuthState>(context, listen: false);

    try {
      final cliente = await FirebaseService.clientAuth.loginCliente(telefono, password);

      // Verify the navigator is still mounted before using its context
      if (!nav.mounted) return;

      if (cliente != null) {
        _tentativiAccesso.remove(telefono);
        _blocchiTemporanei.remove(telefono);

        authState.login(cliente);

        nav.pop();
        _showPointsSelectionDialog(nav.context, cliente);
      } else {
        _gestisciTentativoFallito(telefono);
        _showErrorDialog(nav.context, 'Credenziali non valide');
      }
    } catch (e) {
      if (nav.mounted) {
        _showErrorDialog(nav.context, 'Errore durante il login: $e');
      }
    }
  }

  void _registraCliente(BuildContext context, String nome, String cognome, String telefono, String password) async {
    // Capture navigator, scaffold and authState before awaiting
    final nav = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    final authState = Provider.of<AuthState>(context, listen: false);

    try {
      final user = await FirebaseService.clientAuth.registraCliente(nome, cognome, telefono, password, 0);

      // Ensure navigator still mounted before popping
      if (nav.mounted) {
        nav.pop();
      }

      authState.login(user);

      if (scaffold.mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('\u2705 Registrazione completata! Benvenuto $nome!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      if (nav.mounted) {
        _showErrorDialog(nav.context, 'Errore durante la registrazione: $e');
      } else if (scaffold.mounted) {
        scaffold.showSnackBar(
          SnackBar(content: Text('Errore durante la registrazione: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPointsSelectionDialog(BuildContext context, Cliente user) {
    // Questo verrà implementato nel controller principale
  }

  // 👇 METODI DI SICUREZZA
  void _gestisciTentativoFallito(String telefono) {
    final tentativi = (_tentativiAccesso[telefono] ?? 0) + 1;
    _tentativiAccesso[telefono] = tentativi;
    
    if (tentativi >= 5) {
      _blocchiTemporanei[telefono] = DateTime.now().add(const Duration(minutes: 15));
    }
  }

  bool _isTelefonoBloccato(String telefono) {
    final bloccoFino = _blocchiTemporanei[telefono];
    if (bloccoFino != null && DateTime.now().isBefore(bloccoFino)) {
      return true;
    }
    
    if (bloccoFino != null && DateTime.now().isAfter(bloccoFino)) {
      _blocchiTemporanei.remove(telefono);
      _tentativiAccesso.remove(telefono);
    }
    
    return false;
  }

  void _mostraMessaggioBlocco(BuildContext context, String telefono) {
    final bloccoFino = _blocchiTemporanei[telefono]!;
    final minutiRimanenti = bloccoFino.difference(DateTime.now()).inMinutes + 1;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚫 Accesso Temporaneamente Bloccato'),
        content: Text(
          'Troppi tentativi falliti. Riprova tra $minutiRimanenti minuti per proteggere il tuo account.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        message: message,
        onRiprova: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _recuperaPassword(BuildContext context) {
    // Implementazione esistente...
  }
}