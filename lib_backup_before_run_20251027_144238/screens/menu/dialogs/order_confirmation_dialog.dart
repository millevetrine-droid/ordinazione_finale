import 'package:flutter/material.dart';

class OrderConfirmationDialog extends StatelessWidget {
  final double totalPrice;
  final int totalItems;
  final VoidCallback onNoGrazie;
  final VoidCallback onSiAccumula;

  const OrderConfirmationDialog({
    super.key,
    required this.totalPrice,
    required this.totalItems,
    required this.onNoGrazie,
    required this.onSiAccumula,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B8A), Color(0xFFFF8E42)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ACCUMULA PUNTI?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Totale: €${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$totalItems ${totalItems == 1 ? 'piatto' : 'piatti'} nel carrello',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Vuoi accumulare ${totalPrice.toInt()} punti per questo ordine?',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // SCELTA: SÌ o NO
            Column(
              children: [
                // BOTTONE NO
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNoGrazie,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'NO GRAZIE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // BOTTONE SÌ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSiAccumula,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'SÌ, ACCUMULA!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}