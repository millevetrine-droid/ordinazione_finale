import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import '../../../models/pietanza_model.dart';

class ProductCard extends StatelessWidget {
  final Pietanza pietanza;
  final int quantita;
  final Function(int) onQuantityChanged;

  const ProductCard({
    super.key,
    required this.pietanza,
    required this.quantita,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacitySafe(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Immagine prodotto
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                pietanza.immagine,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
          
          // Contenuto card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome prodotto
                Text(
                  pietanza.nome,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Descrizione
                if (pietanza.descrizione.isNotEmpty)
                  Text(
                    pietanza.descrizione,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 12),
                
                // Prezzo e pulsante aggiungi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prezzo
                    Text(
                      '€${pietanza.prezzo.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    
                    // Pulsante aggiungi/quantità
                    Container(
                      decoration: BoxDecoration(
                        color: quantita > 0 ? const Color(0xFF8B4513) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (quantita > 0)
                            IconButton(
                              onPressed: () => onQuantityChanged(quantita - 1),
                              icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                          
                          if (quantita > 0)
                            Text(
                              quantita.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          
                          IconButton(
                            onPressed: () => onQuantityChanged(quantita + 1),
                            icon: Icon(
                              quantita > 0 ? Icons.add : Icons.add_shopping_cart,
                              color: quantita > 0 ? Colors.white : Colors.grey[700],
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}