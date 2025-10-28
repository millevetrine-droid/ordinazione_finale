/// FILE: pietanza_row.dart
/// SCOPO: Widget per visualizzazione riga pietanza in schermate cucina con pulsanti azione stato
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - ordine_model.dart (modello ordine)
///   - pietanza_model.dart (modello pietanza)
///   - action_buttons.dart (pulsanti azione standardizzati)
/// - Importato da:
///   - schermate cucina per gestione stati pietanze
///   - ordine_card.dart (composizione card ordine)
/// - Dipendenze:
///   - package:flutter/material.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione compatta pietanza con emoji e nome
/// - Indicatore stato corrente con colore
/// - Pulsanti azione contestuali (Inizia/Pronto)
/// - Gestione transizioni di stato
/// - Design coerente con tema cucina
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATO uso pietanza.iconaVisualizzata invece di pietanza.emoji
/// - 2024-01-20: MANTENUTA logica transizioni stato esistente
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione emoji dal modello aggiornato
/// - Funzionamento callback onAzionePressed
/// - Stati e colori coerenti con workflow
library;

import 'package:flutter/material.dart';
import 'package:ordinazione/core/models/ordine_model.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'action_buttons.dart';

// === CLASSE: PIETANZA ROW ===
// Scopo: Widget per riga pietanza in interfacce cucina con gestione stati
// Note: Mostra pulsanti azione contestuali in base allo stato corrente
class PietanzaRow extends StatelessWidget {
  final Pietanza pietanza;
  final Ordine ordine;
  final Function onAzionePressed;

  const PietanzaRow({
    super.key,
    required this.pietanza,
    required this.ordine,
    required this.onAzionePressed,
  });

  @override
  Widget build(BuildContext context) {
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
          // === SEZIONE INFO PIETANZA ===
          Expanded(
            child: Row(
              children: [
                // Emoji pietanza - ✅ CORRETTO: usa iconaVisualizzata
                Text(
                  pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                
                // Nome e stato pietanza
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
                      
                      // Stato corrente
                      Text(
                        pietanza.statoTesto,
                        style: TextStyle(
                          color: pietanza.coloreStato,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // === SEZIONE PULSANTI AZIONE ===
          _buildPulsanteAzione(),
        ],
      ),
    );
  }

  // === WIDGET: PULSANTE AZIONE ===
  /// Restituisce il pulsante azione appropriato in base allo stato
  /// Stati supportati: InAttesa -> Inizia, InPreparazione -> Pronto
  Widget _buildPulsanteAzione() {
    if (pietanza.isInAttesa) {
      return ActionButtons.buildPulsantePietanza(
        'Inizia',
        Colors.blue,
        () => onAzionePressed(
          ordine: ordine,
          pietanza: pietanza,
          nuovoStato: StatoPietanza.inPreparazione,
        ),
      );
    } else if (pietanza.isInPreparazione) {
      return ActionButtons.buildPulsantePietanza(
        'Pronto',
        Colors.green,
        () => onAzionePressed(
          ordine: ordine,
          pietanza: pietanza,
          nuovoStato: StatoPietanza.pronto,
        ),
      );
    }
    
    // Nessun pulsante per altri stati
    return const SizedBox.shrink();
  }
}