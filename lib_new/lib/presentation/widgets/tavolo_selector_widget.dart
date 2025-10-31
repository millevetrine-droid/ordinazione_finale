import 'package:flutter/material.dart';

class TavoloSelectorWidget extends StatelessWidget {
  final String? tavoloSelezionato;
  final Function(String) onTavoloSelezionato;

  const TavoloSelectorWidget({
    super.key,
    required this.tavoloSelezionato,
    required this.onTavoloSelezionato,
  });

  final List<String> tavoli = const [
    'Tavolo 1', 'Tavolo 2', 'Tavolo 3', 'Tavolo 4',
    'Tavolo 5', 'Tavolo 6', 'Tavolo 7', 'Tavolo 8',
    'Bancone', 'Take Away'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.table_restaurant, color: Colors.orange),
            const SizedBox(width: 8),
            const Text(
              'Seleziona Tavolo:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (tavoloSelezionato != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tavoloSelezionato!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tavoli.length,
            itemBuilder: (context, index) {
              final tavolo = tavoli[index];
              final isSelezionato = tavoloSelezionato == tavolo;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(tavolo),
                  selected: isSelezionato,
                  onSelected: (selected) {
                    if (selected) {
                      onTavoloSelezionato(tavolo);
                    }
                  },
                  selectedColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: isSelezionato ? Colors.white : Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}