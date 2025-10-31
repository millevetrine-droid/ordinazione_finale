import 'package:flutter/material.dart';
import 'package:ordinazione/core/services/firebase_service.dart';

class ResetPasswordRequestScreen extends StatefulWidget {
  const ResetPasswordRequestScreen({super.key});

  @override
  State<ResetPasswordRequestScreen> createState() => _ResetPasswordRequestScreenState();
}

class _ResetPasswordRequestScreenState extends State<ResetPasswordRequestScreen> {
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final telefono = _telefonoController.text.trim();
    final email = _emailController.text.trim();
    if (telefono.isEmpty || email.isEmpty) return;
    setState(() => _loading = true);

    try {
      // generate token
  final token = await FirebaseService().clientAuth.generateResetToken(telefono);

      // send email via legacy EmailService (expects appBaseUrl configured)
      final sent = await FirebaseService.email.sendPasswordResetTokenEmail(
        toEmail: email,
        customerName: telefono,
        resetToken: token,
        appBaseUrl: 'https://example.com/reset-password',
      );

      if (sent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email inviata. Controlla la tua posta.')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore invio email')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recupera password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Telefono')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email registrata')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loading ? null : _sendReset, child: _loading ? const CircularProgressIndicator() : const Text('Invia email di recupero')),
          ],
        ),
      ),
    );
  }
}
