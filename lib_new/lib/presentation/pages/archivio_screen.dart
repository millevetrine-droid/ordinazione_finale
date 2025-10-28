/// FILE: archivio_screen.dart
/// SCOPO: Schermata visualizzazione ordini archiviati/completati con storico dettagliato
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - ordini_provider.dart (gestione stato ordini)
///   - ordine_model.dart (modello dati ordine)
///   - pietanza_model.dart (modello dati pietanza)
/// - Importato da:
///   - proprietario_screen.dart (navigazione tab)
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione completa ordini completati/archiviati
/// - Dettaglio pietanze per ogni ordine con emoji e prezzi
/// - Info tavolo, timestamp e totale ordine
/// - Design clean ottimizzato per consultazione
/// - Gestione visualizzazione allergeni dalle pietanze
/// - Badge stato "COMPLETATO" per chiara identificazione
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATI tutti i riferimenti allergeni per usare pietanza.haAllergeni e pietanza.testoAllergeni
/// - 2024-01-20: CORRETTI type mismatch emoji usando pietanza.iconaVisualizzata
/// - 2024-01-20: MANTENUTA struttura visualizzazione esistente
/// - 2024-01-20: AGGIUNTA documentazione completa per manutenzione futura
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione allergeni dal modello aggiornato
/// - Caricamento corretto ordini archiviati dal provider
/// - Formattazione timestamp consistente
/// - Calcolo totali ordine accurato
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/ordini_provider.dart';
import 'package:ordinazione/core/models/ordine_model.dart';
// ✅ AGGIUNTO per referenza diretta

// === CLASSE: ARCHIVIO SCREEN ===
// Scopo: Schermata stateless per visualizzazione ordini archiviati
// Note: Design pulito e informativo per consultazione storica
class ArchivioScreen extends StatelessWidget {
  const ArchivioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('ARCHIVIO ORDINI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withAlpha((0.6 * 255).round()),
          child: Consumer<OrdiniProvider>(
            builder: (context, ordiniProvider, child) {
              final archivioOrdini = ordiniProvider.archivioOrdini;

              // === STATO VUOTO ===
              if (archivioOrdini.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive, color: Colors.white, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Nessun ordine in archivio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gli ordini completati appariranno qui',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // === LISTA ORDINI ARCHIVIATI ===
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: archivioOrdini.length,
                itemBuilder: (context, index) {
                  final ordine = archivioOrdini[index];
                  return _buildOrdineCard(ordine);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // === WIDGET: ORDINE CARD ===
  /// Card singola ordine archiviato con dettagli completi
  Widget _buildOrdineCard(Ordine ordine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha((0.5 * 255).round())),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER ORDINE ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info tavolo
                Row(
                  children: [
                    const Icon(Icons.table_restaurant, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tavolo ${ordine.numeroTavolo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Badge stato completato
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'COMPLETATO',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // === LISTA PIETANZE ===
            Column(
              children: ordine.pietanze.map((pietanza) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Emoji pietanza - ✅ CORRETTO: usa iconaVisualizzata
                    Text(
                      pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    
                    // Nome pietanza
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pietanza.nome,
                            style: const TextStyle(color: Colors.white),
                          ),
                          // ✅ CORRETTO: Visualizzazione allergeni con getter del modello
                          if (pietanza.haAllergeni)
                            Text(
                              '⚠️ Allergeni: ${pietanza.testoAllergeni}', // ✅ CORRETTO: usa getter del modello
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Prezzo pietanza
                    Text(
                      '€${pietanza.prezzo.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.yellow),
                    ),
                  ],
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // === TOTALE E TIMESTAMP ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Totale ordine
                Text(
                  'Totale: €${ordine.totale.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Timestamp ordine
                Text(
                  _formatTime(ordine.timestamp),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === METODO: FORMAT TIME ===
  /// Formatta DateTime in stringa ore:minuti
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}