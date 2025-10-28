import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/transazione_model.dart'; // 👈 CORREGGI QUESTO IMPORT

class ArchivioSeraleScreen extends StatelessWidget {
  const ArchivioSeraleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 ARCHIVIO SERALE'),
        backgroundColor: Colors.deepOrange[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<Transazione>>(
        stream: FirebaseService.archive.getTransazioni(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transazioni = snapshot.data ?? [];

          if (transazioni.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Nessuna transazione archiviata',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // CALCOLA STATISTICHE
          final totaleIncasso = transazioni.fold(0.0, (sum, t) => sum + t.importo);
          final numeroTavoli = transazioni.map((t) => t.tavolo).toSet().length;
          final metodoPreferito = _calcolaMetodoPreferito(transazioni);

          return Column(
            children: [
              // STATISTICHE
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('📈 STATISTICHE SERALI', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatistica('Totale Incasso', '€${totaleIncasso.toStringAsFixed(2)}', Colors.green),
                          _buildStatistica('Tavoli Serviti', numeroTavoli.toString(), Colors.blue),
                          _buildStatistica('Pagamento Pref.', metodoPreferito, Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // LISTA TRANSAZIONI
              Expanded(
                child: ListView.builder(
                  itemCount: transazioni.length,
                  itemBuilder: (context, index) {
                    return _buildTransazioneCard(transazioni[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistica(String titolo, String valore, Color colore) {
    return Column(
      children: [
        Text(titolo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(valore, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colore)),
      ],
    );
  }

  Widget _buildTransazioneCard(Transazione transazione) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🛎️ Tavolo ${transazione.tavolo}', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(
                    transazione.metodoPagamento.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: _getColoreMetodo(transazione.metodoPagamento),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('💰 Importo: €${transazione.importo.toStringAsFixed(2)}'),
            Text('⏰ Ora: ${_formatTime(transazione.data)}'),
            if (transazione.note != null) 
              Text('📝 Note: ${transazione.note}'),
          ],
        ),
      ),
    );
  }

  Color _getColoreMetodo(String metodo) {
    switch (metodo) {
      case 'contanti': return Colors.green;
      case 'carta': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _calcolaMetodoPreferito(List<Transazione> transazioni) {
    if (transazioni.isEmpty) return '-';
    
    final conteggio = <String, int>{};
    for (final transazione in transazioni) {
      conteggio[transazione.metodoPagamento] = 
          (conteggio[transazione.metodoPagamento] ?? 0) + 1;
    }
    
    return conteggio.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _formatTime(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}