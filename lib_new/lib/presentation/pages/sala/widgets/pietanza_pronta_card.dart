/// FILE: pietanza_pronta_card.dart
/// SCOPO: Widget per visualizzazione pietanze pronte da servire in sala con info tempo trascorso
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - ordine_model.dart (modello ordine)
///   - pietanza_model.dart (modello pietanza)
///   - ordini_provider.dart (gestione stato ordini)
///   - auth_provider.dart (autenticazione utente)
///   - action_buttons_sala.dart (pulsanti azione sala standardizzati)
/// - Importato da:
///   - schermate sala per gestione pietanze pronte
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione compatta pietanze pronte per servizio
/// - Timer trascorso dall'ordine con color coding
/// - Pulsante consegna al tavolo
/// - Gestione note ordine
/// - Integrazione con OrdiniProvider per aggiornamento stato
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATO uso pietanza.iconaVisualizzata invece di pietanza.emoji
/// - 2024-01-20: MANTENUTA logica tempi e colori esistente
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione emoji dal modello aggiornato
/// - Calcolo corretto tempo trascorso
/// - Funzionamento pulsante consegna con OrdiniProvider
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/ordini_provider.dart';
import 'package:ordinazione/core/providers/auth_provider.dart';
import 'package:ordinazione/core/models/ordine_model.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'action_buttons_sala.dart';

// === CLASSE: PIETANZA PRONTA CARD ===
// Scopo: Widget compatto per pietanze pronte da servire in sala
// Note: Design ottimizzato per liste dense con info essenziali
class PietanzaProntaCard extends StatelessWidget {
  final Ordine ordine;
  final Pietanza pietanza;
  final String tavolo;

  const PietanzaProntaCard({
    super.key,
    required this.ordine,
    required this.pietanza,
    required this.tavolo,
  });

  @override
  Widget build(BuildContext context) {
    // Calcolo tempo trascorso dall'ordine
    final minutiTrascorsi = DateTime.now().difference(ordine.timestamp).inMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.9 * 255).round()),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withAlpha((0.6 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha((0.2 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER COMPATTO ===
            Row(
              children: [
                // Container emoji pietanza
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Center(
                    child: Text(
                      pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Info pietanza e tavolo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pietanza.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Tavolo $tavolo • ${_formatTime(ordine.timestamp)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badge tempo trascorso
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getColoreTempo(minutiTrascorsi),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$minutiTrascorsi min',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // === SEZIONE NOTE (condizionale) ===
            if (ordine.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.orange.withAlpha((0.3 * 255).round())),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, color: Colors.orange, size: 12),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ordine.note,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // === PULSANTE CONSEGNA ===
            const SizedBox(height: 10),
            ActionButtonsSala.buildAzioneButton(
              'CONSEGNA AL TAVOLO $tavolo',
              Colors.purple,
              () => _segnaPietanzaServita(context),
            ),
          ],
        ),
      ),
    );
  }

  // === METODO: GET COLORE TEMPO ===
  /// Restituisce colore in base al tempo trascorso (verde -> arancione -> rosso)
  Color _getColoreTempo(int minuti) {
    if (minuti <= 5) return Colors.green;
    if (minuti <= 10) return Colors.orange;
    return Colors.red;
  }

  // === METODO: SEGNA PIETANZA SERVITA ===
  /// Segna la pietanza come servita tramite OrdiniProvider
  void _segnaPietanzaServita(BuildContext context) {
    final ordiniProvider = Provider.of<OrdiniProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    ordiniProvider.segnaPietanzaServita(
      ordineId: ordine.id,
      pietanzaId: pietanza.id,
      user: authProvider.user!.username,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pietanza.nome} consegnato al Tavolo $tavolo'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  // === METODO: FORMAT TIME ===
  /// Formatta DateTime in stringa ore:minuti
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}