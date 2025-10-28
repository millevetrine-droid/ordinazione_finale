import 'package:flutter/material.dart';
import '../models/ordine_model.dart';
import '../services/firebase_service.dart';

class CassaScreen extends StatefulWidget {
  const CassaScreen({super.key});

  @override
  State<CassaScreen> createState() => _CassaScreenState();
}

class _CassaScreenState extends State<CassaScreen> {
  String? _tavoloSelezionato;
  final List<Ordine> _ordiniTavolo = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 CASSA - Gestione Pagamenti'),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<Ordine>>(
        stream: FirebaseService.orders.getTuttiOrdini(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ordini = snapshot.data ?? [];
          final tavoli = _getTavoliConOrdini(ordini);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // SELEZIONE TAVOLO
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('🛎️ Seleziona Tavolo', 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: tavoli.map((tavolo) {
                            return FilterChip(
                              label: Text('Tavolo $tavolo'),
                              selected: _tavoloSelezionato == tavolo,
                              onSelected: (selected) {
                                setState(() {
                                  _tavoloSelezionato = selected ? tavolo : null;
                                  _ordiniTavolo.clear();
                                  if (selected) {
                                    _ordiniTavolo.addAll(
                                      ordini.where((o) => o.tavolo == tavolo)
                                    );
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // DETTAGLIO ORDINE E PAGAMENTO
                if (_tavoloSelezionato != null) 
                  _buildDettaglioPagamento(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDettaglioPagamento() {
    final totale = _ordiniTavolo.fold(0.0, (sum, ordine) => sum + ordine.totale);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💳 Conto Tavolo $_tavoloSelezionato', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            // LISTA PIETANZE
            ..._ordiniTavolo.expand((ordine) => ordine.pietanze).map((pietanza) {
              return ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text('${pietanza.nome} x${pietanza.quantita}'),
                trailing: Text('€ ${(pietanza.prezzo * pietanza.quantita).toStringAsFixed(2)}'),
              );
            }),

            const Divider(),

            // TOTALE
            ListTile(
              leading: const Icon(Icons.payments, color: Colors.green),
              title: const Text('TOTALE', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('€ ${totale.toStringAsFixed(2)}', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ),

            const SizedBox(height: 20),

            // METODO PAGAMENTO
            const Text('💳 Metodo di pagamento:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 10),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _processaPagamento('contanti', totale),
                    icon: const Icon(Icons.money),
                    label: const Text('CONTANTI'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _processaPagamento('carta', totale),
                    icon: const Icon(Icons.credit_card),
                    label: const Text('CARTA'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getTavoliConOrdini(List<Ordine> ordini) {
    return ordini.map((o) => o.tavolo).toSet().toList();
  }

  void _processaPagamento(String metodo, double totale) async {
    // PREPARA DATI TRANSAZIONE
    final pietanze = _ordiniTavolo.expand((o) => o.pietanze).map((p) {
        return {
          'nome': p.nome,
          'prezzo': p.prezzo,
          'quantita': p.quantita,
        };
      }).toList();

    // Capture messenger and navigator before awaiting to avoid using BuildContext
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // REGISTRA PAGAMENTO
      await FirebaseService.archive.registraPagamento(
        tavolo: _tavoloSelezionato!,
        importo: totale,
        metodoPagamento: metodo,
        pietanze: pietanze,
        note: 'Pagamento effettuato',
      );

      // ARCHIVIA ORDINI
      for (final ordine in _ordiniTavolo) {
        await FirebaseService.orders.archiviaOrdineCompletato(ordine.id);
      }

      // SUCCESSO
      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ Pagamento di € ${totale.toStringAsFixed(2)} registrato!'),
          backgroundColor: Colors.green,
        ),
      );

      // TORNA INDIETRO
      navigator.pop();

    } catch (e) {
      // messenger is already captured above
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}