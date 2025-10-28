import 'package:flutter/material.dart';

class PuntiScreen extends StatelessWidget {
  const PuntiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Content-only: embedded inside parent Scaffold in Home
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.loyalty, size: 80, color: Colors.purple),
          SizedBox(height: 20),
          Text(
            'I MIEI PUNTI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Programma fedeltà in sviluppo',
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