/// FILE: visualizza_cucina_screen.dart
/// SCOPO: Schermata visualizzazione sola lettura per stato cucina con dettaglio completo ordini
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - ordini_provider.dart (gestione stato ordini)
///   - ordine_model.dart (modello dati ordine)
///   - pietanza_model.dart (modello dati pietanza)
/// - Importato da:
///   - navigazione principale app
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione completa stato ordini cucina (sola lettura)
/// - Dettaglio stati individuali per ogni pietanza
/// - Timer trascorso per ogni ordine
/// - Riepilogo stati pietanze per ordine
/// - Gestione note ordine
/// - Color coding stati per facile identificazione
/// - Gestione visualizzazione allergeni dalle pietanze
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATI tutti i riferimenti allergeni per usare pietanza.haAllergeni e pietanza.testoAllergeni
/// - 2024-01-20: CORRETTI type mismatch emoji usando pietanza.iconaVisualizzata
/// - 2024-01-20: MANTENUTA logica visualizzazione esistente
/// - 2024-01-20: AGGIUNTA documentazione completa per manutenzione futura
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione allergeni dal modello aggiornato
/// - Calcolo corretto tempi trascorsi
/// - Riepilogo stati accurato
/// - Color coding consistente con workflow
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ordini_provider.dart';
import '../../core/models/ordine_model.dart';
import '../../core/models/pietanza_model.dart';

// === CLASSE: VISUALIZZA CUCINA SCREEN ===
// Scopo: Schermata stateless per visualizzazione sola lettura stato cucina
// Note: Design informativo per monitoraggio senza interazione
class VisualizzaCucinaScreen extends StatelessWidget {
  const VisualizzaCucinaScreen({super.key});

  // === METODO: GET STATO TESTO ===
  /// Converte enum StatoOrdine in testo leggibile
  String _getStatoTesto(StatoOrdine stato) {
    if (stato == StatoOrdine.inAttesa) return 'In Attesa';
    if (stato == StatoOrdine.inPreparazione) return 'In Preparazione';
    if (stato == StatoOrdine.pronto) return 'Pronto';
    if (stato == StatoOrdine.servito) return 'Servito';
    if (stato == StatoOrdine.completato) return 'Completato';
    return 'Sconosciuto';
  }

  // === METODO: GET COLORE STATO ===
  /// Restituisce colore associato allo stato ordine
  Color _getColoreStato(StatoOrdine stato) {
    if (stato == StatoOrdine.inAttesa) return Colors.orange;
    if (stato == StatoOrdine.inPreparazione) return Colors.blue;
    if (stato == StatoOrdine.pronto) return Colors.green;
    if (stato == StatoOrdine.servito) return Colors.purple;
    if (stato == StatoOrdine.completato) return Colors.grey;
    return Colors.grey;
  }

  // === METODO: FORMAT TIME ===
  /// Formatta DateTime in stringa ore:minuti
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // === WIDGET BUILD ===
  /// Costruzione interfaccia utente principale
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('VISTA CUCINA - Solo Visualizzazione'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withAlpha((0.7 * 255).round()),
          child: Consumer<OrdiniProvider>(
            builder: (context, ordiniProvider, child) {
              final ordiniCucina = ordiniProvider.getOrdiniCucinaForCameriere();

              // === STATO VUOTO ===
              if (ordiniCucina.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu, color: Colors.white, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Nessun ordine in cucina',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'La cucina è al momento vuota',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // === LISTA ORDINI CUCINA ===
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ordiniCucina.length,
                itemBuilder: (context, index) {
                  final ordine = ordiniCucina[index];
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
  /// Card singola ordine con dettaglio completo stati pietanze
  Widget _buildOrdineCard(Ordine ordine) {
    final minutiTrascorsi = DateTime.now().difference(ordine.timestamp).inMinutes;
    final conteggioStati = _calcolaConteggioStatiPietanze(ordine.pietanze);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(12),
  border: Border.all(color: _getColoreStato(ordine.stato).withAlpha((0.3 * 255).round())),
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
                // Badge stato ordine
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColoreStato(ordine.stato).withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getColoreStato(ordine.stato)),
                  ),
                  child: Text(
                    _getStatoTesto(ordine.stato).toUpperCase(),
                    style: TextStyle(
                      color: _getColoreStato(ordine.stato),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // === TEMPO TRASCORSO ===
            Text(
              'Tempo trascorso: $minutiTrascorsi minuti',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 8),

            // === RIEPILOGO STATI ===
            _buildRiepilogoStati(conteggioStati, ordine.pietanze.length),

            const SizedBox(height: 12),

            // === LISTA PIETANZE ===
            Column(
              children: ordine.pietanze.map((pietanza) => _buildPietanzaRow(pietanza)).toList(),
            ),

            // === NOTE ORDINE (se presenti) ===
            if (ordine.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.withAlpha((0.3 * 255).round())),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ordine.note,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // === TIMESTAMP ORDINE ===
            Text(
              'Ordine ricevuto: ${_formatTime(ordine.timestamp)}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET: RIEPILOGO STATI ===
  /// Riepilogo contatori stati pietanze per ordine
  Widget _buildRiepilogoStati(Map<String, int> conteggio, int totalePietanze) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
  color: Colors.white.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatoIndicator('In Attesa', Colors.orange, conteggio['inAttesa'] ?? 0),
          _buildStatoIndicator('In Prep.', Colors.blue, conteggio['inPreparazione'] ?? 0),
          _buildStatoIndicator('Pronto', Colors.green, conteggio['pronte'] ?? 0),
          _buildStatoIndicator('Totale', Colors.white, totalePietanze),
        ],
      ),
    );
  }

  // === WIDGET: STATO INDICATOR ===
  /// Indicatore singolo stato con contatore
  Widget _buildStatoIndicator(String label, Color color, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // === WIDGET: PIETANZA ROW ===
  /// Riga singola pietanza con stato e info
  Widget _buildPietanzaRow(Pietanza pietanza) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
  color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(6),
  border: Border.all(color: pietanza.coloreStato.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        children: [
          // Emoji pietanza - ✅ CORRETTO: usa iconaVisualizzata
          Text(
            pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          
          // Info pietanza
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome pietanza
                Text(
                  pietanza.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                
                // Stato pietanza
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: pietanza.coloreStato,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pietanza.statoTesto,
                      style: TextStyle(
                        color: pietanza.coloreStato,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

          // Badge stato compatto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: pietanza.coloreStato.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: pietanza.coloreStato.withAlpha((0.5 * 255).round())),
            ),
            child: Text(
              _getStatoPietanzaBadge(pietanza.stato),
              style: TextStyle(
                color: pietanza.coloreStato,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === METODO: GET STATO PIETANZA BADGE ===
  /// Testo compatto per badge stato pietanza
  String _getStatoPietanzaBadge(StatoPietanza stato) {
    if (stato == StatoPietanza.inAttesa) return 'ATTESA';
    if (stato == StatoPietanza.inPreparazione) return 'IN PREP.';
    if (stato == StatoPietanza.pronto) return 'PRONTO';
    if (stato == StatoPietanza.servito) return 'SERVITO';
    return 'SCONOSCIUTO';
  }

  // === METODO: CALCOLA CONTEGGIO STATI ===
  /// Calcola contatori stati pietanze per riepilogo
  Map<String, int> _calcolaConteggioStatiPietanze(List<Pietanza> pietanze) {
    final inAttesa = pietanze.where((p) => p.isInAttesa).length;
    final inPreparazione = pietanze.where((p) => p.isInPreparazione).length;
    final pronte = pietanze.where((p) => p.isPronto).length;

    return {
      'inAttesa': inAttesa,
      'inPreparazione': inPreparazione,
      'pronte': pronte,
    };
  }
}