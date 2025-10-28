import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';

class CompactCartBar extends StatelessWidget {
  final VoidCallback onViewCart;
  final VoidCallback onCheckout;

  const CompactCartBar({
    super.key,
    required this.onViewCart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.itemCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.yellow, // ✅ SFONDO GIALLO
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Info carrello
              Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.black, size: 20), // ✅ TESTO NERO
                  const SizedBox(width: 8),
                  Text(
                    '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'articolo' : 'articoli'}',
                    style: const TextStyle(
                      color: Colors.black, // ✅ TESTO NERO
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• €${cartProvider.totale.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black87, // ✅ TESTO NERO
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Bottoni azione
              Row(
                children: [
                  // Bottone Vedi Carrello
                  OutlinedButton(
                    onPressed: onViewCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // ✅ TESTO NERO
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text(
                      'VEDI CARRELLO',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Bottone Checkout
                  ElevatedButton(
                    onPressed: onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // ✅ BOTTONE NERO
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'CHECKOUT',
                      style: TextStyle(
                        color: Colors.yellow, // ✅ TESTO GIALLO
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}