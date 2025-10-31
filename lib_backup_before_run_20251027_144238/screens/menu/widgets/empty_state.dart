import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String? categoriaSelezionata;

  const EmptyState({
    super.key,
    this.categoriaSelezionata,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nessuna pietanza disponibile',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            categoriaSelezionata == null 
                ? 'Prova a selezionare una categoria specifica'
                : 'Nessuna pietanza in questa categoria',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}