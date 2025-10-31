import 'package:flutter/material.dart'; // ✅ AGGIUNGI QUESTO IMPORT
import '../models/ordine_model.dart';
import '../models/pietanza_model.dart';

class OrderService {
  static Ordine creaOrdine({
    required String numeroTavolo,
    required List<Pietanza> pietanze,
    required String idCameriere,
    String note = '',
  }) {
    return Ordine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      numeroTavolo: numeroTavolo,
      pietanze: pietanze,
      stato: StatoOrdine.inAttesa,
      timestamp: DateTime.now(),
      idCameriere: idCameriere,
      note: note,
    );
  }

  // ✅ METODI UTILITY CORRETTI
  static String formattaOra(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  static IconData getStatoIcona(StatoOrdine stato) {
    return switch (stato) {
      StatoOrdine.inAttesa => Icons.access_time,
      StatoOrdine.inPreparazione => Icons.restaurant,
      StatoOrdine.pronto => Icons.check_circle,
      StatoOrdine.servito => Icons.local_dining,
      StatoOrdine.completato => Icons.done_all,
    }; // ✅ AGGIUNTO PUNTO E VIRGOLA
  }

  static String getStatoTesto(StatoOrdine stato) {
    return switch (stato) {
      StatoOrdine.inAttesa => 'In Attesa',
      StatoOrdine.inPreparazione => 'In Preparazione',
      StatoOrdine.pronto => 'Pronto',
      StatoOrdine.servito => 'Servito',
      StatoOrdine.completato => 'Completato',
    }; // ✅ AGGIUNTO PUNTO E VIRGOLA
  }
}