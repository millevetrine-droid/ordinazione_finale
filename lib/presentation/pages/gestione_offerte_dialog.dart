import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'gestione_offerte_controller.dart';

class GestioneOfferteDialog {
  static void mostra({
    required BuildContext context,
    required GestioneOfferteController controller,
    Map<String, dynamic>? offertaEsistente,
    required Function onSalva,
  }) {
    final isModifica = offertaEsistente != null;
    
    final titoloController = TextEditingController(text: offertaEsistente?['titolo'] ?? '');
    final sottotitoloController = TextEditingController(text: offertaEsistente?['sottotitolo'] ?? '');
    final prezzoController = TextEditingController(text: offertaEsistente?['prezzo']?.toString() ?? '');
  // Do not prefill an emoji by default — leave empty so the owner must
  // explicitly enter an emoji. A default emoji confused owners into
  // thinking the field was already populated by the customer.
  final immagineController = TextEditingController(text: offertaEsistente?['immagine'] ?? '');
    
  // No link selection in the simplified offer form. Saved offers will
  // use linkTipo='ordina' so customers tapping the offer go directly to the cart.

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return _buildDialogContent(
            context: context,
            isModifica: isModifica,
            titoloController: titoloController,
            sottotitoloController: sottotitoloController,
            prezzoController: prezzoController,
            immagineController: immagineController,
            controller: controller,
            setDialogState: setDialogState,
            onSalva: () => onSalva(
              titoloController.text,
              sottotitoloController.text,
              double.tryParse(prezzoController.text) ?? 0.0,
              immagineController.text,
              'ordina',
              '',
              offertaEsistente?['id'],
            ),
          );
        }
      ),
    );
  }

  static Widget _buildDialogContent({
    required BuildContext context,
    required bool isModifica,
    required TextEditingController titoloController,
    required TextEditingController sottotitoloController,
    required TextEditingController prezzoController,
    required TextEditingController immagineController,
  // linkTipo/linkDestinazione removed from dialog (saved implicitly)
    required GestioneOfferteController controller,
    required Function setDialogState,
    required Function onSalva,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(isModifica ? '✏️ Modifica Offerta' : '➕ Nuova Offerta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titoloController,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Titolo offerta *',
                hintText: 'Es: 🍔 MENU DEL GIORNO',
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            TextField(
              controller: sottotitoloController,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Descrizione *',
                hintText: 'Es: Panino + Patatine + Bibita',
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            TextField(
              controller: prezzoController,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Prezzo (€) *',
                hintText: 'Es: 12.90',
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(color: Colors.black),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: immagineController,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Emoji *',
                hintText: 'Es: 🍔 (usa tastiera emoji)',
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            
            const SizedBox(height: 10),
            
            const SizedBox(height: 10),
            const Text(
              '* Campi obbligatori\nUsa la tastiera del telefono per le emoji',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ANNULLA'),
        ),
            ElevatedButton(
              onPressed: () {
                try {
                  dev.log('GestioneOfferteDialog: SALVA button pressed - titolo=${titoloController.text}', name: 'GestioneOfferteDialog');
                } catch (_) {}

                onSalva();
                Navigator.pop(context);
              },
              child: Text(isModifica ? 'MODIFICA' : 'SALVA'),
            ),
      ],
    );
  }

  // Link selection helpers removed — offer creation is simplified.
}
