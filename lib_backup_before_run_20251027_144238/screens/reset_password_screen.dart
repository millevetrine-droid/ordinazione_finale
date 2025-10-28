import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _telefonoController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _telefonoController.dispose();
    _tokenController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final telefono = _telefonoController.text.trim();
    final token = _tokenController.text.trim();
    final newPass = _newPassController.text.trim();
    if (telefono.isEmpty || token.isEmpty || newPass.isEmpty) return;
    setState(() => _loading = true);

    // Capture messenger and navigator before async gaps
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      final valid = await FirebaseService.clientAuth.verifyResetToken(telefono, token);
      if (!valid) {
        if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Token non valido o scaduto')));
        return;
      }

      final ok = await FirebaseService.clientAuth.setNewPassword(telefono, newPass);
      if (mounted) {
        if (ok) {
          messenger.showSnackBar(const SnackBar(content: Text('Password aggiornata')));
          nav.pop();
        } else {
          messenger.showSnackBar(const SnackBar(content: Text('Errore aggiornamento password')));
        }
      }
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text('Errore: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imposta nuova password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Telefono')),
            TextField(controller: _tokenController, decoration: const InputDecoration(labelText: 'Token ricevuto via email')),
            TextField(controller: _newPassController, decoration: const InputDecoration(labelText: 'Nuova password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Imposta nuova password')),
          ],
        ),
      ),
    );
  }
}
