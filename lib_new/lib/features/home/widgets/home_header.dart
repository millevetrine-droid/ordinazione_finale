import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String? userName;
  final bool hasSessioneAttiva;
  final int? numeroTavolo;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.hasSessioneAttiva,
    required this.numeroTavolo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.restaurant,
          size: 60,
          color: Color(0xFFFF6B8B),
        ),
        const SizedBox(height: 10),
        const Text(
          'RISTORANTE MILLE VETRINE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Benvenuto, ${userName ?? 'Cliente'}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        if (hasSessioneAttiva)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              'Tavolo $numeroTavolo',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}