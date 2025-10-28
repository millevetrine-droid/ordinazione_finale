import 'package:flutter/material.dart';
import '../models/ordine_model.dart';
import '../services/firebase_service.dart';
import 'archivio_sala_screen.dart'; // 🔥 IMPORT AGGIUNTO

class SalaScreen extends StatefulWidget {
  const SalaScreen({super.key});

  @override
  State<SalaScreen> createState() => _SalaScreenState();
}

class _SalaScreenState extends State<SalaScreen> {
  bool _mostraStatoCompleto = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💁 SALA - Gestione Ordini'),
        backgroundColor: Colors.green[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 🔥 PULSANTE ARCHIVIO SALA AGGIUNTO
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ArchivioSalaScreen()),
              );
            },
            tooltip: 'Archivio sala',
          ),
          IconButton(
            icon: Icon(_mostraStatoCompleto ? Icons.done_all : Icons.visibility),
            onPressed: () {
              setState(() {
                _mostraStatoCompleto = !_mostraStatoCompleto;
              });
            },
            tooltip: _mostraStatoCompleto 
                ? 'Mostra solo ordini pronti' 
                : 'Mostra stato completo cucina',
          ),
        ],
      ),
      body: StreamBuilder<List<Ordine>>(
        stream: _mostraStatoCompleto 
            ? FirebaseService.orders.getTuttiOrdini()
            : FirebaseService.orders.getOrdiniSala(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final ordini = snapshot.data ?? [];

          final ordiniFiltrati = ordini.where((ordine) {
            if (_mostraStatoCompleto) {
              return ordine.pietanze.any((p) => p.stato != 'consegnato');
            } else {
              return ordine.pietanze.any((p) => p.stato == 'pronto');
            }
          }).toList();

          if (ordiniFiltrati.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _mostraStatoCompleto ? Icons.visibility_off : Icons.done_all,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _mostraStatoCompleto 
                        ? 'Nessun ordine in lavorazione'
                        : 'Nessun ordine pronto per la consegna',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: ordiniFiltrati.length,
            itemBuilder: (context, index) {
              final ordine = ordiniFiltrati[index];
              return _buildOrdineCard(ordine, _mostraStatoCompleto);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrdineCard(Ordine ordine, bool mostraStatoCompleto) {
    final pietanzeDaMostrare = mostraStatoCompleto
        ? ordine.pietanze.where((p) => p.stato != 'consegnato').toList()
        : ordine.pietanze.where((p) => p.stato == 'pronto').toList();

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      color: mostraStatoCompleto ? Colors.blue[50] : Colors.green[50],
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
                    mostraStatoCompleto 
                        ? '${pietanzeDaMostrare.length} in lavorazione'
                        : '${pietanzeDaMostrare.length} da consegnare',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: mostraStatoCompleto ? Colors.blue : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('📅 ${_formatTime(ordine.timestamp)}'),
            Text('👥 Persone: ${ordine.numeroPersone}'),
            const SizedBox(height: 12),
            Text(
              mostraStatoCompleto ? '👨‍🍳 Stato cucina:' : '🍽️ Ordini pronti:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...pietanzeDaMostrare.map((pietanza) => 
              _buildPietanzaItem(ordine.id, pietanza, mostraStatoCompleto)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPietanzaItem(String ordineId, PietanzaOrdine pietanza, bool isSoloVisualizzazione) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: _getColoreStatoPietanza(pietanza.stato),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ${pietanza.nome} x${pietanza.quantita}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '€ ${(pietanza.prezzo * pietanza.quantita).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildStatoPietanza(pietanza.stato),
                ],
              ),
            ),
            if (!isSoloVisualizzazione && pietanza.stato == 'pronto')
              ElevatedButton(
                onPressed: () => _consegnaPietanza(ordineId, pietanza),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('DA CONSEGNARE'),
              ),
            if (isSoloVisualizzazione)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getColoreStato(pietanza.stato),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getTestoStato(pietanza.stato),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getColoreStatoPietanza(String stato) {
    switch (stato) {
      case 'in_attesa': return Colors.grey[100]!;
      case 'in_preparazione': return Colors.orange[50]!;
      case 'pronto': return Colors.green[100]!;
      case 'consegnato': return Colors.blue[50]!;
      default: return Colors.grey[100]!;
    }
  }

  Color _getColoreStato(String stato) {
    switch (stato) {
      case 'in_attesa': return Colors.grey;
      case 'in_preparazione': return Colors.orange;
      case 'pronto': return Colors.green;
      case 'consegnato': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildStatoPietanza(String stato) {
    Color colore = _getColoreStato(stato);
    String testo = _getTestoStato(stato);
    
    return Text(
      testo,
      style: TextStyle(color: colore, fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  String _getTestoStato(String stato) {
    switch (stato) {
      case 'in_attesa': return '⏳ IN ATTESA';
      case 'in_preparazione': return '👨‍🍳 IN PREPARAZIONE';
      case 'pronto': return '✅ PRONTO';
      case 'consegnato': return '📦 CONSEGNATO';
      default: return '❓ SCONOSCIUTO';
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _consegnaPietanza(String ordineId, PietanzaOrdine pietanza) async {
    // Capture messenger before async gap
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 👇 CORRETTO: Chiamata al metodo con parametri corretti
      await FirebaseService.orders.aggiornaStatoPietanza(
        ordineId,
        pietanza.idPietanza,
        'consegnato',
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Pietanza consegnata con successo!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}