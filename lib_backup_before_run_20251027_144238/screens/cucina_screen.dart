import 'package:flutter/material.dart';
import '../models/ordine_model.dart';
import '../models/pietanza_model.dart';
import '../services/firebase_service.dart';
import 'archivio_cucina_screen.dart'; // 🔥 IMPORT AGGIUNTO

class CucinaScreen extends StatefulWidget {
  const CucinaScreen({super.key});

  @override
  State<CucinaScreen> createState() => _CucinaScreenState();
}

class _CucinaScreenState extends State<CucinaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍🍳 CUCINA - Ordini in Corso'),
        backgroundColor: Colors.orange[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 🔥 PULSANTE ARCHIVIO AGGIUNTO
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ArchivioCucinaScreen()),
              );
            },
            tooltip: 'Archivio cucina',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<List<Ordine>>(
        stream: FirebaseService.orders.getOrdiniCucina(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final ordini = snapshot.data ?? [];

          // 🔥 CORREZIONE: Filtra gli ordini che hanno ALMENO UNA pietanza da preparare
          final ordiniConPietanzeAttive = ordini.where((ordine) {
            return ordine.pietanze.any((p) {
              final s = _statoToString(p.stato);
              return s == 'in_attesa' || s == 'in_preparazione';
            });
          }).toList();

          if (ordiniConPietanzeAttive.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_food_beverage, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Nessun ordine in cucina',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Gli ordini appariranno qui automaticamente',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: ordiniConPietanzeAttive.length,
            itemBuilder: (context, index) {
              final ordine = ordiniConPietanzeAttive[index];
              return _buildOrdineCard(ordine);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrdineCard(Ordine ordine) {
    // 🔥 CORREZIONE: Mostra solo le pietanze in attesa o in preparazione
    final pietanzeDaPreparare = ordine.pietanze.where((p) {
      final s = _statoToString(p.stato);
      return s == 'in_attesa' || s == 'in_preparazione';
    }).toList();

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🛎️ Tavolo ${ordine.tavolo}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    '${pietanzeDaPreparare.length} da preparare',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('📅 ${_formatTime(ordine.timestamp)}'),
            Text('👥 Persone: ${ordine.numeroPersone}'),
            const SizedBox(height: 12),
            const Text('🍽️ Pietanze da preparare:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...pietanzeDaPreparare.map((pietanza) {
              return _buildPietanzaItem(ordine.id, pietanza);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPietanzaItem(String ordineId, dynamic pietanza) {
    // Accept both canonical Pietanza and legacy PietanzaOrdine
    final id = (pietanza is Pietanza) ? pietanza.id : (pietanza.idPietanza ?? '');
    final nome = (pietanza is Pietanza) ? pietanza.nome : pietanza.nome;
    final quantita = (pietanza is Pietanza) ? pietanza.quantita : pietanza.quantita;
    final prezzo = (pietanza is Pietanza) ? pietanza.prezzo : (pietanza.prezzo as double);
    final stato = _statoToString(pietanza.stato);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: _getPietanzaColor(pietanza.stato),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• $nome x$quantita', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('€ ${(prezzo * quantita).toStringAsFixed(2)} - ${_getStatoText(stato)}'),
                ],
              ),
            ),
            if (stato == 'in_attesa')
              ElevatedButton(
                onPressed: () => _cambiaStatoPietanza(ordineId, id, 'in_preparazione'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text('INIZIA'),
              ),
            if (stato == 'in_preparazione')
              ElevatedButton(
                onPressed: () => _cambiaStatoPietanza(ordineId, id, 'pronto'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text('PRONTO'),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPietanzaColor(String stato) {
    switch (stato) {
      case 'in_attesa': return Colors.orange[100]!;
      case 'in_preparazione': return Colors.blue[100]!;
      case 'pronto': return Colors.green[100]!;
      default: return Colors.grey[100]!;
    }
  }

  String _getStatoText(String stato) {
    switch (stato) {
      case 'in_attesa': return 'IN ATTESA';
      case 'in_preparazione': return 'IN PREPARAZIONE';
      case 'pronto': return 'PRONTO';
      default: return stato.toUpperCase();
    }
  }

  String _statoToString(dynamic stato) {
    if (stato == null) return 'in_attesa';
    if (stato is String) return stato;
    // Stato may be an enum (StatoPietanza) from canonical model
    try {
      switch (stato) {
        case StatoPietanza.inAttesa:
          return 'in_attesa';
        case StatoPietanza.inPreparazione:
          return 'in_preparazione';
        case StatoPietanza.pronto:
          return 'pronto';
        case StatoPietanza.servito:
          return 'consegnato';
      }
    } catch (_) {}
    return stato.toString();
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _cambiaStatoPietanza(String ordineId, String pietanzaId, String nuovoStato) async {
    // Capture messenger before async gap so it's available in catch
    final messenger = ScaffoldMessenger.of(context);

    try {
      // 👇 CORRETTO: Chiamata al metodo con parametri corretti
      await FirebaseService.orders.aggiornaStatoPietanza(
        ordineId,
        pietanzaId,
        nuovoStato,
      );

      // Feedback visivo per l'utente
      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ Stato aggiornato a: ${_getStatoText(nuovoStato)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'), 
          backgroundColor: Colors.red
        ),
      );
    }
  }
}