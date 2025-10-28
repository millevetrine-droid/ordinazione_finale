import 'package:flutter/material.dart';

class OffertePlaceholder extends StatelessWidget {
  const OffertePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'OFFERTE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sezione offerte in sviluppo',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}


