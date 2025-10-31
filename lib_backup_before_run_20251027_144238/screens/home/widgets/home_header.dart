import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'ultra_small_button.dart';

class HomeHeader extends StatelessWidget {
  final String? currentTavolo;
  final VoidCallback onTestPressed;
  final VoidCallback onStaffPressed;

  const HomeHeader({
    super.key,
    required this.currentTavolo,
    required this.onTestPressed,
    required this.onStaffPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UltraSmallButton(
                text: '🎯 MENU DI PROVA',
                subtitle: 'Solo per test',
                onPressed: onTestPressed,
              ),
              if (currentTavolo != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacitySafe(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.table_restaurant, size: 14, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Tavolo $currentTavolo',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
              IconButton(
                onPressed: onStaffPressed,
                  icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacitySafe(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacitySafe(0.3), width: 1),
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 380,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
              color: Colors.black.withOpacitySafe(0.7),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacitySafe(0.4), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFF6B8B),
                        child: const Icon(Icons.restaurant, size: 60, color: Colors.white),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'MAGNO RESTAURANT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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