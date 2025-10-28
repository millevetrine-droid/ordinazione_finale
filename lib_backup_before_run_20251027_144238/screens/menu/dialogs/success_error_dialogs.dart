import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final int nuoviPunti;
  final VoidCallback onOk;

  const SuccessDialog({
    super.key,
    required this.message,
    required this.nuoviPunti,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 50),
            const SizedBox(height: 20),
            const Text(
              'ORDINE CONFERMATO!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Punti totali: $nuoviPunti',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onOk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback onRiprova;

  const ErrorDialog({
    super.key,
    required this.message,
    required this.onRiprova,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 50),
            const SizedBox(height: 20),
            const Text(
              'ERRORE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRiprova,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'RIPROVA',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}