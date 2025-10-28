import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/ordini_provider.dart';
import 'ordine_recuperabile_sala_card.dart';

class TabArchivioSala extends StatelessWidget {
  const TabArchivioSala({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdiniProvider>(
      builder: (context, ordiniProvider, child) {
        final ordiniRecuperabili = ordiniProvider.getOrdiniRecuperabiliCameriere();

        if (ordiniRecuperabili.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ordiniRecuperabili.length,
          itemBuilder: (context, index) {
            final ordine = ordiniRecuperabili[index];
            return OrdineRecuperabileSalaCard(ordine: ordine);
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
            'Le pietanze segnate servite per errore appariranno qui',
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