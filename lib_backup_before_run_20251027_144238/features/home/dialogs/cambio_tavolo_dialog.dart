import 'package:flutter/material.dart';

class CambioTavoloDialog {
  static void show({
    required BuildContext context,
    required String currentTavolo,
    required String nuovoTavolo,
    required Function(String) onConferma,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.table_restaurant,
              color: Colors.blue,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Cambio Tavolo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hai ricevuto una nuova prenotazione:',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // 🔥 TAVOLO CORRENTE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.table_restaurant,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tavolo Attuale: $currentTavolo',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 🔥 NUOVO TAVOLO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.table_restaurant,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nuovo Tavolo: $nuovoTavolo',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Vuoi cambiare tavolo?',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // 🔥 BOTTONE ANNULLA
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('RIMANI QUI'),
          ),
          
          // 🔥 BOTTONE CONFERMA
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConferma(nuovoTavolo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('CAMBIATAVOLO'),
          ),
        ],
      ),
    );
  }
}