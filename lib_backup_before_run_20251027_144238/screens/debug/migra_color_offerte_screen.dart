import 'package:flutter/material.dart';
import '../../services/firebase/menu_firestore_service.dart';

class MigraColoriOfferteScreen extends StatefulWidget {
  const MigraColoriOfferteScreen({super.key});

  @override
  State<MigraColoriOfferteScreen> createState() => _MigraColoriOfferteScreenState();
}

class _MigraColoriOfferteScreenState extends State<MigraColoriOfferteScreen> {
  bool _running = false;
  int _updated = 0;

  Future<void> _runMigration() async {
    if (_running) return;
    setState(() => _running = true);
    try {
      final service = MenuFirestoreService();
      final updated = await service.migraColoriOfferte();
      if (!mounted) return;
      setState(() => _updated = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migrazione completata: $updated documenti aggiornati')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore migrazione: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // Don't return from finally; only update state if the widget is still mounted.
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug: Migra colori offerte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Esegui questa migrazione solo in ambiente di sviluppo o con credenziali adeguate.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _running ? null : _runMigration,
              child: _running ? const CircularProgressIndicator() : const Text('Esegui migrazione'),
            ),
            const SizedBox(height: 12),
            Text('Documenti aggiornati: $_updated'),
          ],
        ),
      ),
    );
  }
}
