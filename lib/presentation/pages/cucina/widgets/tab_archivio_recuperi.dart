import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/ordini_provider.dart';
import 'ordine_recuperabile_card.dart';

class TabArchivioRecuperi extends StatelessWidget {
  const TabArchivioRecuperi({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdiniProvider>(
      builder: (context, ordiniProvider, child) {
        final ordiniRecuperabili = ordiniProvider.getOrdiniRecuperabiliCuoco();

        if (ordiniRecuperabili.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ordiniRecuperabili.length,
          itemBuilder: (context, index) {
            final ordine = ordiniRecuperabili[index];
            return OrdineRecuperabileCard(ordine: ordine);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text(
            'Nessun ordine da recuperare',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Le pietanze segnate pronte per errore appariranno qui',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}