import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/cart_provider.dart';
import 'cart/cart_item_widget.dart';

class CartSummaryPanel extends StatelessWidget {
  final VoidCallback onCheckout;
  final double? maxHeight;

  const CartSummaryPanel({
    super.key,
    required this.onCheckout,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final List<CartItem> cartItems = cartProvider.items;
        final hasScroll = maxHeight != null && cartItems.length > 2;

        Widget content = Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Il Tuo Ordine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (cartItems.isNotEmpty)
              ...cartItems.map((cartItem) => CartItemWidget(
                pietanza: cartItem.pietanza,
                quantita: cartItem.quantita,
              )),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(204),
                border: Border.all(color: Colors.white.withAlpha(77)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'pietanza' : 'pietanze'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Totale: €${cartProvider.totale.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: cartProvider.itemCount > 0 ? onCheckout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B8B),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      'INVIA ORDINE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (hasScroll) {
          content = SizedBox(
            height: maxHeight,
            child: SingleChildScrollView(
              child: content,
            ),
          );
        }

        return Container(
          color: Colors.black.withAlpha(230),
          child: content,
        );
      },
    );
  }
}