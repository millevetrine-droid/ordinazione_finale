import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/ordini_provider.dart'; // ✅ CORRETTO PERCORSO
import 'package:ordinazione/core/models/ordine_model.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'pietanza_pronta_card.dart';

class TabPietanzePronte extends StatelessWidget {
  const TabPietanzePronte({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdiniProvider>(
      builder: (context, ordiniProvider, child) {
        final pietanzePronte = ordiniProvider.getPietanzePronteDaServire();

        if (pietanzePronte.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pietanzePronte.length,
          itemBuilder: (context, index) {
            final item = pietanzePronte[index];
            final ordine = item['ordine'] as Ordine;
            final pietanza = item['pietanza'] as Pietanza;
            final tavolo = item['tavolo'] as String;
            
            return PietanzaProntaCard(
              ordine: ordine,
              pietanza: pietanza,
              tavolo: tavolo,
            );
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
          Icon(Icons.local_dining, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text(
            'Nessuna pietanza pronta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Le pietanze pronte appariranno qui automaticamente',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}