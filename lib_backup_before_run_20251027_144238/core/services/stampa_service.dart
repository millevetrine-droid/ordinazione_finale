import '../models/ordine_model.dart';
import 'package:flutter/foundation.dart';

class StampaService {
  /// Genera il contenuto dello scontrino fiscale in formato testo
  String generaScontrinoTestuale({
    required String numeroTavolo,
    required List<PietanzaScontrino> pietanze,
    required DateTime dataOra,
    required String numeroScontrino,
  }) {
    final buffer = StringBuffer();

    // Intestazione ristorante
    buffer.writeln('RISTORANTE MILLE VETRINE');
    buffer.writeln('Via Roma 123, 20121 Milano');
    buffer.writeln('P.IVA: 12345678901');
    buffer.writeln('CF: RSTMLL79M20F205X');
    buffer.writeln('=' * 32);

    // Dati scontrino
    buffer.writeln('SCONTRINO FISCALE N. $numeroScontrino');
    buffer.writeln('Data: ${_formattaData(dataOra)}');
    buffer.writeln('Ora: ${_formattaOra(dataOra)}');
    buffer.writeln('Tavolo: $numeroTavolo');
    buffer.writeln('-' * 32);

    // Intestazione colonne
    buffer.writeln('DESCRIZIONE            QTA   IMPORTO');
    buffer.writeln('-' * 32);

    // Dettaglio pietanze
    for (final pietanza in pietanze) {
      final descrizione = _troncaTesto(pietanza.nome, 20);
      final importo = _formattaImporto(pietanza.prezzo * pietanza.quantita);
      
      buffer.write(descrizione.padRight(22));
      buffer.write(pietanza.quantita.toString().padLeft(3));
      buffer.writeln(importo.padLeft(7));
    }

    buffer.writeln('-' * 32);

    // Totali
    final totaleImponibile = _calcolaTotaleImponibile(pietanze);
    final iva = _calcolaIVA(totaleImponibile);
    final totale = totaleImponibile + iva;

    buffer.writeln('IMPONIBILE:    ${_formattaImporto(totaleImponibile).padLeft(10)}');
    buffer.writeln('IVA 10%:       ${_formattaImporto(iva).padLeft(10)}');
    buffer.writeln('=' * 32);
    buffer.writeln('TOTALE:        ${_formattaImporto(totale).padLeft(10)}');
    buffer.writeln('=' * 32);

    // Metodo pagamento (da selezionare)
    buffer.writeln('CONTANTI');
    buffer.writeln('-' * 32);

    // Footer
    buffer.writeln('Grazie e arrivederci!');
    buffer.writeln('Servizio al tavolo');
    buffer.writeln('*** SCONTRINO FISCALE ***');

    return buffer.toString();
  }

  /// Genera i dati per la stampa termica (formato compatibile stampanti)
  Map<String, dynamic> generaDatiStampaTermica({
    required String numeroTavolo,
    required List<PietanzaScontrino> pietanze,
    required DateTime dataOra,
    required String numeroScontrino,
  }) {
    final contenutoTestuale = generaScontrinoTestuale(
      numeroTavolo: numeroTavolo,
      pietanze: pietanze,
      dataOra: dataOra,
      numeroScontrino: numeroScontrino,
    );

    return {
      'type': 'text',
      'content': contenutoTestuale,
      'encoding': 'ISO-8859-1',
      'align': 'left',
      'size': 'normal',
      'cut': true,
      'lines': 2,
    };
  }

  /// Genera un numero progressivo per lo scontrino
  String generaNumeroProgressivo() {
    final now = DateTime.now();
    final anno = now.year.toString().substring(2);
    final mese = now.month.toString().padLeft(2, '0');
    final giorno = now.day.toString().padLeft(2, '0');
    final progressivo = now.millisecondsSinceEpoch % 10000;
    
    return '$anno$mese$giorno${progressivo.toString().padLeft(4, '0')}';
  }

  /// Calcola il totale imponibile
  double _calcolaTotaleImponibile(List<PietanzaScontrino> pietanze) {
    return pietanze.fold(0.0, (total, pietanza) => total + (pietanza.prezzo * pietanza.quantita));
  }

  /// Calcola l'IVA al 10%
  double _calcolaIVA(double imponibile) {
    return (imponibile * 0.10);
  }

  /// Formatta un importo in Euro
  String _formattaImporto(double importo) {
    return '€${importo.toStringAsFixed(2)}';
  }

  /// Formatta la data in formato italiano
  String _formattaData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  /// Formatta l'ora in formato italiano
  String _formattaOra(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  /// Tronca il testo alla lunghezza specificata
  String _troncaTesto(String testo, int lunghezzaMax) {
    if (testo.length <= lunghezzaMax) {
      return testo.padRight(lunghezzaMax);
    }
    return '${testo.substring(0, lunghezzaMax - 3)}...';
  }

  /// Simula l'invio alla stampante
  Future<bool> inviaAllaStampante(Map<String, dynamic> datiStampa) async {
    // Simulazione di invio alla stampante termica
    await Future.delayed(const Duration(seconds: 2));
    
    // In un'implementazione reale, qui ci sarebbe l'integrazione
    // con l'SDK della stampante termica (ESCPOS, StarPRNT, etc.)
    
  debugPrint('=== INIZIO SCONTRINO ===');
  debugPrint(datiStampa['content']);
  debugPrint('=== FINE SCONTRINO ===');
    
    return true; // Successo
  }

  /// Esporta lo scontrino in formato PDF (per archiviazione)
  Future<String> esportaPDF({
    required String numeroTavolo,
    required List<PietanzaScontrino> pietanze,
    required DateTime dataOra,
    required String numeroScontrino,
  }) async {
    // Simulazione generazione PDF
    await Future.delayed(const Duration(seconds: 1));
    
    // CORREZIONE: Rimossa variabile non utilizzata
    generaScontrinoTestuale(
      numeroTavolo: numeroTavolo,
      pietanze: pietanze,
      dataOra: dataOra,
      numeroScontrino: numeroScontrino,
    );
    
    // In un'implementazione reale, qui si userebbe un package PDF
    // come pdf o printing
    
    return 'PDF_$numeroScontrino.pdf';
  }
}

/// Modello per i dati delle pietanze nello scontrino
class PietanzaScontrino {
  final String nome;
  final double prezzo;
  final int quantita;

  PietanzaScontrino({
    required this.nome,
    required this.prezzo,
    required this.quantita,
  });
}

/// Estensione per convertire un Ordine in dati per lo scontrino
extension OrdineToScontrino on Ordine {
  List<PietanzaScontrino> toPietanzeScontrino() {
    // CORREZIONE: Rimossa qualifica 'this.' non necessaria
    // Raggruppa le pietanze per nome e calcola le quantità
    final Map<String, PietanzaScontrino> raggruppate = {};
    
    for (final pietanza in pietanze) {
      if (raggruppate.containsKey(pietanza.nome)) {
        raggruppate[pietanza.nome] = PietanzaScontrino(
          nome: pietanza.nome,
          prezzo: pietanza.prezzo,
          quantita: raggruppate[pietanza.nome]!.quantita + 1,
        );
      } else {
        raggruppate[pietanza.nome] = PietanzaScontrino(
          nome: pietanza.nome,
          prezzo: pietanza.prezzo,
          quantita: 1,
        );
      }
    }
    
    return raggruppate.values.toList();
  }
}