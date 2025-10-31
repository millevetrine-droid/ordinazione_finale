/// FILE: lib/features/home/dialogs/selezione_tavolo_dialog.dart
/// SCOPO: Dialog per selezione tavolo di prova
/// 
/// MODIFICHE APPLICATE:
/// - 2024-01-20 - Modificati pulsanti per ritornare valore invece di chiamare callback
library;

import 'package:flutter/material.dart';

class SelezioneTavoloDialog extends StatelessWidget {
  final Function(String) onTavoloSelezionato;

  const SelezioneTavoloDialog({
    super.key,
    required this.onTavoloSelezionato,
  });

  static void show({
    required BuildContext context,
    required Function(String) onTavoloSelezionato,
  }) {
    showDialog(
      context: context,
      builder: (context) => SelezioneTavoloDialog(
        onTavoloSelezionato: onTavoloSelezionato,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('🎯 Seleziona Tavolo di Prova'),
      content: const Text('Scegli un numero di tavolo per testare l\'app:'),
      actions: [
        Wrap(
          spacing: 10,
          children: [1, 2, 3, 4].map((numero) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(numero.toString());
              },
              child: Text('Tavolo $numero'),
            );
          }).toList(),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
      ],
    );
  }
}