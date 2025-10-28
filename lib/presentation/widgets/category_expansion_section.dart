import 'package:flutter/material.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'menu_item_card.dart';

class CategoryExpansionSection extends StatelessWidget {
  final String categoria;
  final List<Pietanza> pietanze;
  final bool isEspansa;
  final VoidCallback onTap;
  final Function(Pietanza) onAddToCart;

  const CategoryExpansionSection({
    super.key,
    required this.categoria,
    required this.pietanze,
    required this.isEspansa,
    required this.onTap,
    required this.onAddToCart,
  });

  Widget _getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'antipasti':
        return const Icon(Icons.emoji_food_beverage, color: Colors.orange);
      case 'primi piatti':
        return const Icon(Icons.dinner_dining, color: Colors.yellow);
      case 'secondi piatti':
        return const Icon(Icons.set_meal, color: Colors.red);
      case 'dolci':
        return const Icon(Icons.cake, color: Colors.pink);
      default:
        return const Icon(Icons.restaurant, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: _getCategoryIcon(categoria),
            title: Text(
              categoria.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              isEspansa ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          if (isEspansa && pietanze.isNotEmpty)
            Column(
              children: pietanze.map((pietanza) => MenuItemCard(
                pietanza: pietanza,
                onAddToCart: () => onAddToCart(pietanza),
              )).toList(),
            ),

          if (isEspansa && pietanze.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nessuna pietanza disponibile in questa categoria',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}