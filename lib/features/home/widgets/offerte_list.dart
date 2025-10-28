import 'package:flutter/material.dart';
import 'offerta_card.dart';

class OfferteList extends StatelessWidget {
  const OfferteList({super.key});

  @override
  Widget build(BuildContext context) {
    final offerte = [
      {
        'titolo': 'Menu Degustazione',
        'descrizione': 'Un viaggio attraverso i sapori della nostra cucina',
        'prezzo': 65.00,
        'immagine': '🍽️',
      },
      {
        'titolo': 'Pizza del Giorno',
        'descrizione': 'Scopri la specialità del nostro pizzaiolo',
        'prezzo': 12.00,
        'immagine': '🍕',
      },
      {
        'titolo': 'Vino della Casa',
        'descrizione': 'Calice di vino selezionato in omaggio',
        'prezzo': 0.00,
        'immagine': '🍷',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offerte.length,
      itemBuilder: (context, index) {
        final offerta = offerte[index];
        return OffertaCard(
          titolo: offerta['titolo'] as String,
          descrizione: offerta['descrizione'] as String,
          prezzo: offerta['prezzo'] as double,
          immagine: offerta['immagine'] as String,
          onTap: () {
            // Navigazione o azione quando si clicca sull'offerta
          },
        );
      },
    );
  }
}