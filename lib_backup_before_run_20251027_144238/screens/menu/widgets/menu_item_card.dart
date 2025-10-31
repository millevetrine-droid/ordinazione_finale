import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:ordinazione/models/pietanza_model.dart';

class MenuItemCard extends StatelessWidget {
  final Pietanza pietanza;
  final int quantita;
  final Function(String, String, double, int) onUpdateQuantity;

  const MenuItemCard({
    super.key,
    required this.pietanza,
    required this.quantita,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
  color: Colors.grey[900]!.withOpacitySafe(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // RIGA 1: TITOLO
            Text(
              pietanza.nome,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            // RIGA 2: DESCRIZIONE
            if (pietanza.descrizione.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                pietanza.descrizione,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // RIGA 3: ALLERGENI
            if (pietanza.allergeni.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '⚠️ ${pietanza.testoAllergeni}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // RIGA 4: 3 COLONNE (Emoji | Prezzo | Quantità)
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // COLONNA 1: EMOJI/FOTO
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(pietanza.categoria),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor(pietanza.categoria).withOpacitySafe(0.4),
                            blurRadius: 5,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          pietanza.iconaVisualizzata,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // COLONNA 2: PREZZO
                Column(
                  children: [
                    Text(
                      '€${pietanza.prezzo.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B8B),
                      ),
                    ),
                  ],
                ),
                
                // COLONNA 3: PULSANTI QUANTITÀ
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Color(0xFFFF6B8B), size: 24),
                          onPressed: quantita > 0 ? () => onUpdateQuantity(pietanza.id, pietanza.nome, pietanza.prezzo, quantita - 1) : null,
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
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFFFF6B8B), size: 24),
                          onPressed: () => onUpdateQuantity(pietanza.id, pietanza.nome, pietanza.prezzo, quantita + 1),
                        ),
                      ],
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

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'ANTIPASTI':
        return const Color(0xFFFFB6C1);
      case 'PRIMI PIATTI':
        return const Color(0xFFFFD700);
      case 'SECONDI PIATTI':
        return const Color(0xFFFFA500);
      case 'CONTORNI':
        return const Color(0xFF98FB98);
      case 'DOLCI':
        return const Color(0xFFDDA0DD);
      case 'BEVANDE':
        return const Color(0xFF87CEEB);
      case 'BIRRE':
        return const Color(0xFFF4A460);
      case 'VINI':
        return const Color(0xFF8B4513);
      default:
        return const Color(0xFFFF6B8B);
    }
  }
}