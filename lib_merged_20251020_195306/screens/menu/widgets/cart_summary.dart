import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import '../../../services/firebase_service.dart';
import '../../../models/pietanza_model.dart';

class CartSummary extends StatelessWidget {
  final String numeroTavolo;
  final Map<String, Map<String, dynamic>> cart;
  final int totalItems;
  final double totalPrice;
  final Function(Pietanza, int) onUpdateQuantity;
  final VoidCallback onConfirmOrder;

  const CartSummary({
    super.key,
    required this.numeroTavolo,
    required this.cart,
    required this.totalItems,
    required this.totalPrice,
    required this.onUpdateQuantity,
    required this.onConfirmOrder,
  });

  @override
  Widget build(BuildContext context) {
    final hasOrdini = totalItems > 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFEC8B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacitySafe(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacitySafe(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intestazione
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🛒 Ordine - Tavolo $numeroTavolo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              Text(
                '$totalItems ${totalItems == 1 ? 'piatto' : 'piatti'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Lista pietanze ordinate (se ci sono ordini)
          if (hasOrdini) ...[
            ...cart.entries.where((entry) => entry.value['quantita'] > 0).map((entry) {
              final pietanzaId = entry.key;
              final itemData = entry.value;
              final pietanza = FirebaseService.menu.pietanzeMenu.firstWhere((p) => p.id == pietanzaId);
              
              return _buildPietanzaCarrelloVisibile(pietanza, itemData['quantita'], onUpdateQuantity);
            }),
            
            const SizedBox(height: 12),
            
            // Totale e pulsante invio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Totale:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    Text(
                      '€ ${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onConfirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B8B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'INVIA ORDINE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Messaggio quando non ci sono ordini
            const Center(
              child: Text(
                'Nessun piatto ordinato\nSeleziona i piatti dal menu qui sotto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8B4513),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPietanzaCarrelloVisibile(Pietanza pietanza, int quantita, Function(Pietanza, int) onUpdateQuantity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEZIONE TITOLO SEPARATA IN ALTO
            Row(
              children: [
                Text(pietanza.immagine, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pietanza.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // SEZIONE INFERIORE: Prezzo e quantità
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Prezzo più grande
                Text(
                  '€ ${(pietanza.prezzo * quantita).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B8B),
                  ),
                ),
                
                // Pulsanti quantità
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.orange, size: 20),
                      onPressed: () => onUpdateQuantity(pietanza, quantita - 1),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B8B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$quantita',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green, size: 20),
                      onPressed: () => onUpdateQuantity(pietanza, quantita + 1),
                    ),
                    
                    // Pulsante cancella
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => onUpdateQuantity(pietanza, 0),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}