import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/models/pietanza_model.dart';
import 'cart_item_widget.dart';

class CartDetailedView extends StatelessWidget {
  final VoidCallback onCheckout;

  const CartDetailedView({
    super.key,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.8 * 255).round()),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Il tuo Carrello',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),

        // Lista pietanze
        Expanded(
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              // ✅ CORRETTO: Ora cartProvider.items è List<CartItem>, non List<Pietanza>
              if (cartProvider.items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Il carrello è vuoto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Aggiungi qualche pietanza dal menu',
                        style: TextStyle(
                            color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ✅ CORRETTO: Raggruppa le pietanze per ID e conta le quantità usando CartItem
              final Map<String, MapEntry<Pietanza, int>> pietanzeRaggruppate = {};
              
              for (final cartItem in cartProvider.items) {
                final pietanzaId = cartItem.pietanza.id; // ✅ ACCEDI A pietanza.id
                if (pietanzeRaggruppate.containsKey(pietanzaId)) {
                  final entry = pietanzeRaggruppate[pietanzaId]!;
                  pietanzeRaggruppate[pietanzaId] = MapEntry(entry.key, entry.value + cartItem.quantita);
                } else {
                  pietanzeRaggruppate[pietanzaId] = MapEntry(cartItem.pietanza, cartItem.quantita);
                }
              }

              final items = pietanzeRaggruppate.values.toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final entry = items[index];
                  return CartItemWidget(
                    pietanza: entry.key,
                    quantita: entry.value,
                  );
                },
              );
            },
          ),
        ),

        // Totale e checkout
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.9 * 255).round()),
            border: Border.all(color: Colors.white.withAlpha((0.3 * 255).round())),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Totale:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '€${cartProvider.totale.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B8B),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCheckout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B8B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'PROCEDI AL CHECKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}