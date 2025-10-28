/// FILE: cart_item_widget.dart
/// SCOPO: Widget per visualizzare un item del carrello con controlli quantità e info allergeni
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - pietanza_model.dart (modello dati pietanza)
///   - cart_provider.dart (gestione stato carrello)
/// - Importato da:
///   - cart_detailed_view.dart (visualizzazione dettagliata carrello)
///   - compact_cart_bar.dart (barra carrello compatta)
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione item carrello con emoji, nome, prezzo
/// - Controlli incremento/decremento quantità
/// - Gestione visualizzazione ingredienti e allergeni
/// - Integrazione con CartProvider per aggiornamenti stato
/// - UI compatta per utilizzo in liste
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATO uso pietanza.iconaVisualizzata invece di pietanza.emoji
/// - 2024-01-20: AGGIORNATO riferimento allergeni usando pietanza.haAllergeni
/// - 2024-01-20: MANTENUTA logica esistente di gestione quantità
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione allergeni dal modello aggiornato
/// - Funzionamento pulsanti quantità con CartProvider
/// - Responsività layout su diversi dispositivi
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/cart_provider.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';

// === CLASSE: CART ITEM WIDGET ===
// Scopo: Widget stateless per visualizzare un item del carrello
// Note: Utilizza Consumer per aggiornamenti reattivi al cambio quantità
class CartItemWidget extends StatelessWidget {
  final Pietanza pietanza;
  final int quantita;

  const CartItemWidget({
    super.key,
    required this.pietanza,
    required this.quantita,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(8),
  border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === SEZIONE: EMOJI PIETANZA ===
          // Scopo: Visualizzazione rappresentativa della pietanza
          // Correzione: Usa iconaVisualizzata che restituisce sempre String
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          // === SEZIONE: DETTAGLI PIETANZA ===
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome pietanza
                  Text(
                    pietanza.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // Lista ingredienti (se presente)
                  if (pietanza.ingredienti.isNotEmpty)
                    Text(
                      pietanza.ingredienti.join(', '),
                      style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Allergeni (se presenti) - ✅ AGGIORNATO: usa haAllergeni
                  if (pietanza.haAllergeni) // ✅ CORRETTO: usa getter del modello
                    Text(
                      '⚠️ Allergeni: ${pietanza.testoAllergeni}', // ✅ CORRETTO: usa getter del modello
                      style: TextStyle(
                        color: Colors.orange.withAlpha(204),
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Prezzo
                  Text(
                    '€${pietanza.prezzo.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B8B),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === SEZIONE: CONTROLLI QUANTITÀ ===
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Pulsante incremento
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B8B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: () => cartProvider.aggiungiAlCarrello(pietanza),
                    icon: const Icon(Icons.add, size: 12, color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Quantità corrente
                Text(
                  quantita.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Pulsante decremento
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(204),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: () => cartProvider.rimuoviDalCarrello(pietanza.id),
                    icon: const Icon(Icons.remove, size: 12, color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}