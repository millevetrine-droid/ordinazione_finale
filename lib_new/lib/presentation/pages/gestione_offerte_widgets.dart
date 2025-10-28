import 'package:flutter/material.dart';
import 'gestione_offerte_controller.dart';

class GestioneOfferteWidgets {
  static Widget buildOffertaCard({
    required Map<String, dynamic> offerta,
    required GestioneOfferteController controller,
    required Function onModifica,
    required Function onElimina,
    required Function onCambiaStato,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink[50],
          child: Text(
            offerta['immagine'] ?? '🎁',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(
          offerta['titolo'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: offerta['attiva'] == true ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offerta['sottotitolo'] ?? ''),
            Text(
              '€${(offerta['prezzo'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Text(
              controller.getTipoLinkTesto(offerta['linkTipo'], offerta['linkDestinazione']),
              style: const TextStyle(fontSize: 11, color: Colors.blue),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                offerta['attiva'] == true ? Icons.toggle_on : Icons.toggle_off,
                color: offerta['attiva'] == true ? Colors.green : Colors.grey,
                size: 30,
              ),
              onPressed: () => onCambiaStato(),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'modifica') {
                  onModifica();
                } else if (value == 'elimina') {
                  onElimina();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'modifica',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Modifica'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'elimina',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Elimina'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> mostraConfermaElimina(BuildContext context) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('🗑️ Elimina Offerta'),
        content: const Text('Sei sicuro di voler eliminare questa offerta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );

    return conferma == true;
  }

  static void mostraMessaggioWithMessenger(ScaffoldMessengerState messenger, String messaggio) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: messaggio.contains('❌') ? Colors.red : Colors.green,
      ),
    );
  }

  static void mostraMessaggio(BuildContext context, String messaggio) {
    final messenger = ScaffoldMessenger.of(context);
    mostraMessaggioWithMessenger(messenger, messaggio);
  }
}
