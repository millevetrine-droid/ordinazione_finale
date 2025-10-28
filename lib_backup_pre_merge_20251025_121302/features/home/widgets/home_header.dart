import 'package:flutter/material.dart';
import '../../../presentation/pages/profilo_cliente_screen.dart';
import '../../../presentation/pages/enter_phone_screen.dart';

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
        // Row with welcome text and a profile button that opens the customer profile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Benvenuto, ${userName ?? 'Cliente'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Apri profilo cliente',
                icon: const Icon(Icons.person_outline, color: Colors.white70),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const EnterPhoneScreen()),
                  );
                },
              ),
            ],
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