import 'package:flutter/material.dart';
import '../../core/models/pietanza_model.dart';

class MenuItemCard extends StatelessWidget {
  final Pietanza pietanza;
  final VoidCallback onAddToCart;

  const MenuItemCard({
    super.key,
    required this.pietanza,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  color: Colors.black.withAlpha((0.8 * 255).round()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Immagine/Icona
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.1 * 255).round()),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
                // CORREZIONE: Usa pietanza.emoji invece di pietanza.immagine
                child: Text(
                  pietanza.emoji ?? '',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
          ),

          // Contenuto
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pietanza.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (pietanza.ingredienti.isNotEmpty)
                  Text(
                    pietanza.ingredienti.join(', '),
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '€${pietanza.prezzo.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFFF6B8B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B8B),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}