import 'package:flutter/material.dart';
import 'package:ordinazione/core/services/firebase_service.dart' as core_fb;

class PulisciDatabaseScreen extends StatelessWidget {
  const PulisciDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔄 Pulizia Database'),
        backgroundColor: Colors.red[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'PULIZIA DATABASE',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Questa operazione cancellerà TUTTI gli ordini dal database.\n\n'
              '⚠️  ATTENZIONE: Questa operazione è IRREVERSIBILE!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _confermaPulizia(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text('CANCELLA TUTTI GLI ORDINI'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pulisciOrdiniCompletati(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.cleaning_services),
              label: const Text('PULISCI SOLO ORDINI COMPLETATI'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ANNULLA'),
            ),
          ],
        ),
      ),
    );
  }

  void _confermaPulizia(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Conferma Cancellazione'),
        content: const Text('Sei sicuro di voler cancellare TUTTI gli ordini?\n\nQuesta operazione non può essere annullata!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eseguiPuliziaCompleta(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CANCELLA TUTTO'),
          ),
        ],
      ),
    );
  }

  void _pulisciOrdiniCompletati(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🧹 Pulizia Ordini Completati'),
        content: const Text('Vuoi cancellare solo gli ordini completamente consegnati?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eseguiPuliziaOrdiniCompletati(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('PULISCI'),
          ),
        ],
      ),
    );
  }

  void _eseguiPuliziaCompleta(BuildContext context) async {
    // Capture navigator and messenger before any async gaps
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      // Mostra indicatore di caricamento
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Cancellazione in corso...'),
          duration: Duration(seconds: 5),
        ),
      );

  final firestore = core_fb.FirebaseService().firestore;
      
      // Recupera tutti gli ordini
      final ordiniSnapshot = await firestore.collection('ordini').get();
      
      // Cancella ogni ordine
      final batch = firestore.batch();
      for (final doc in ordiniSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();

      // Nascondi snackbar precedente e mostra successo
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('\u2705 Database pulito con successo!'),
          backgroundColor: Colors.green,
        ),
      );

      // Torna indietro dopo 2 secondi
      await Future.delayed(const Duration(seconds: 2));
      nav.pop();

    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('\u274c Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _eseguiPuliziaOrdiniCompletati(BuildContext context) async {
    // Capture messenger and navigator before any async gaps
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Pulizia ordini completati...'),
          duration: Duration(seconds: 5),
        ),
      );

  final firestore = core_fb.FirebaseService().firestore;
      final ordiniSnapshot = await firestore.collection('ordini').get();
      
      final batch = firestore.batch();
      int ordiniCancellati = 0;

      for (final doc in ordiniSnapshot.docs) {
        final data = doc.data();
        final pietanze = data['pietanze'] as List?;
        
        // Verifica se tutte le pietanze sono consegnate
        if (pietanze != null) {
          final tutteConsegnate = pietanze.every((p) => 
            (p is Map && p['stato'] == 'consegnato')
          );
          
          if (tutteConsegnate) {
            batch.delete(doc.reference);
            ordiniCancellati++;
          }
        }
      }
      
      await batch.commit();

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('\u2705 Cancellati $ordiniCancellati ordini completati!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      nav.pop();

    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('\u274c Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}