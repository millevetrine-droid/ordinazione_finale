import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/ordine_model.dart';

class ArchivioSalaScreen extends StatelessWidget {
  const ArchivioSalaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 ARCHIVIO SALA'),
        backgroundColor: Colors.deepOrange[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService.archive.getArchivioSala(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final archivio = snapshot.data ?? [];

          if (archivio.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Nessuna pietanza in archivio sala',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Le pietanze consegnate archiviate appariranno qui',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: archivio.length,
            itemBuilder: (context, index) {
              final item = archivio[index];
              return _buildArchivioItem(item, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildArchivioItem(Map<String, dynamic> item, BuildContext context) {
    final pietanza = item['pietanza'] as PietanzaOrdine;
    final String tavolo = item['tavolo'] ?? 'N/A';
    final Timestamp timestamp = item['data_archiviazione'];
    final DateTime dataArchiviazione = timestamp.toDate();

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTESTAZIONE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🛎️ Tavolo $tavolo',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Chip(
                  label: Text(
                    'CONSEGNATA',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // DATA ARCHIVIAZIONE
            Text(
              '📅 Archiviata: ${_formatTime(dataArchiviazione)}',
              style: const TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 12),
            
            // DETTAGLI PIETANZA
            const Text(
              '🍽️ Pietanza archiviata:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),
            
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.white,
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
                          const Text(
                            'Stato: CONSEGNATA (archiviata)',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // PULSANTE RIPRISTINA
                    ElevatedButton.icon(
                      onPressed: () => _confermaRipristino(context, item['id'], pietanza.nome),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.replay),
                      label: const Text('RIPRISTINA'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confermaRipristino(BuildContext context, String archivioId, String nomePietanza) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔄 Ripristina Pietanza'),
        content: Text('Vuoi ripristinare "$nomePietanza" in sala?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              _ripristinaPietanza(context, archivioId, messenger);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('RIPRISTINA'),
          ),
        ],
      ),
    );
  }

  void _ripristinaPietanza(BuildContext context, String archivioId, ScaffoldMessengerState messenger) async {
    try {
      await FirebaseService.archive.ripristinaPietanzaDaArchivioSala(archivioId);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Pietanza ripristinata in sala!'),
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

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} del ${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}