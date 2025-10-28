/// FILE: pietanza_list_item.dart
/// SCOPO: Widget per visualizzazione compatta di una pietanza in liste con pulsante aggiunta al carrello
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - pietanza_model.dart (modello dati pietanza)
/// - Importato da:
///   - category_items_screen.dart (lista pietanze per categoria)
///   - vari widget di liste pietanze
/// - Dipendenze:
///   - package:flutter/material.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione compatta pietanza con emoji, nome, descrizione
/// - Pulsante aggiunta al carrello
/// - Gestione visualizzazione ingredienti e allergeni
/// - Prezzo in evidenza
/// - Layout responsive per liste
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATO uso pietanza.iconaVisualizzata invece di pietanza.emoji
/// - 2024-01-20: AGGIORNATO riferimento allergeni usando pietanza.haAllergeni
/// - 2024-01-20: MANTENUTA struttura UI esistente
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione da modello aggiornato
/// - Funzionamento callback onAddToCart
/// - Layout su diverse dimensioni schermo
library;

import 'package:flutter/material.dart';
import '../../core/models/pietanza_model.dart';

// === CLASSE: PIETANZA LIST ITEM ===
// Scopo: Widget stateless per item di lista pietanze
// Note: Design compatto per utilizzo in liste scrollabili
class PietanzaListItem extends StatelessWidget {
  final Pietanza pietanza;
  final VoidCallback onAddToCart;

  const PietanzaListItem({
    super.key,
    required this.pietanza,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ AGGIORNATO: usa getter del modello per allergeni
  final hasAllergeni = pietanza.haAllergeni;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha(204),
        borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === RIGA 1: ICONA + TITOLO + BOTTONE ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icona pietanza - ✅ CORRETTO: usa iconaVisualizzata
                _buildEmoji(),
                
                const SizedBox(width: 12),
                
                // Titolo e descrizione
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome pietanza
                      Text(
                        pietanza.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Descrizione principale
                      if (pietanza.descrizione.isNotEmpty)
                        Text(
                          pietanza.descrizione,
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      // Ingredienti come sottodescrizione
                      if (pietanza.ingredienti.isNotEmpty)
                        Text(
                          'Ingredienti: ${pietanza.ingredienti.join(', ')}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(128),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                
                // Bottone aggiungi al carrello
                ElevatedButton(
                  onPressed: onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B8B),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text(
                    'AGGIUNGI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // === RIGA 2: ALLERGENI + PREZZO ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Allergeni - ✅ AGGIORNATO: usa getter del modello
                if (hasAllergeni)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Allergeni: ${pietanza.testoAllergeni}', // ✅ CORRETTO: usa getter del modello
                            style: TextStyle(
                              color: Colors.orange.withAlpha(204),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Prezzo
                Text(
                  '€${pietanza.prezzo.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B8B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET: BUILD EMOJI ===
  /// Costruisce il container per l'emoji/icona della pietanza
  /// ✅ CORRETTO: Usa iconaVisualizzata che restituisce sempre String
  Widget _buildEmoji() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
  color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}