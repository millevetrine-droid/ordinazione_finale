import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/ordini_provider.dart'; // ✅ CORRETTO PERCORSO
import 'package:ordinazione/core/models/ordine_model.dart';
import 'ordine_card.dart';

class TabOrdiniAttivi extends StatelessWidget {
  const TabOrdiniAttivi({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdiniProvider>(
      builder: (context, ordiniProvider, child) {
        final ordiniCucina = ordiniProvider.ordini.where((ordine) => 
          ordine.stato == StatoOrdine.inAttesa || 
          ordine.stato == StatoOrdine.inPreparazione
        ).toList();

        if (ordiniCucina.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ordiniCucina.length,
          itemBuilder: (context, index) {
            final ordine = ordiniCucina[index];
            return OrdineCard(ordine: ordine);
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
          Icon(Icons.restaurant_menu, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text(
            'Nessun ordine in cucina',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gli ordini appariranno qui',
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