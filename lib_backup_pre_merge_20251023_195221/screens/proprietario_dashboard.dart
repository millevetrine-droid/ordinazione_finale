import 'package:flutter/material.dart';
import '../models/ordine_model.dart';
import 'proprietario_widgets.dart';

class ProprietarioDashboard extends StatelessWidget {
  final List<Ordine> ordini;

  const ProprietarioDashboard({super.key, required this.ordini});

  @override
  Widget build(BuildContext context) {
    final ordiniAttivi = ordini.where((o) => o.statoComplessivo != 'consegnato').length;
    final pietanzeInLavorazione = ordini.expand((o) => o.pietanze)
        .where((p) => p.stato == 'in_attesa' || p.stato == 'in_preparazione').length;
    final pietanzePronte = ordini.expand((o) => o.pietanze).where((p) => p.stato == 'pronto').length;
    final incassoGiornaliero = ordini.where((o) => o.statoComplessivo == 'consegnato')
        .fold(0.0, (sum, ordine) => sum + ordine.totale);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProprietarioWidgets.buildStatCompact('📊', 'Ordini', ordiniAttivi.toString(), Colors.blue),
                  ProprietarioWidgets.buildStatCompact('👨‍🍳', 'In Lavoro', pietanzeInLavorazione.toString(), Colors.orange),
                  ProprietarioWidgets.buildStatCompact('✅', 'Pronti', pietanzePronte.toString(), Colors.green),
                  ProprietarioWidgets.buildStatCompact('💰', 'Incasso', '€${incassoGiornaliero.toStringAsFixed(0)}', Colors.deepOrange),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: ProprietarioWidgets.buildActionButtons(context),
            ),
          ),

          if (ordiniAttivi > 0) ...[
            const SizedBox(height: 10),
            _buildOrdiniInCorso(ordini, ordiniAttivi),
          ],
        ],
      ),
    );
  }

  Widget _buildOrdiniInCorso(List<Ordine> ordini, int ordiniAttivi) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 ORDINI IN CORSO', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            ...ordini.take(2).map((ordine) => ListTile(
              dense: true,
              leading: const Icon(Icons.table_restaurant, size: 20, color: Colors.deepOrange),
              title: Text('Tavolo ${ordine.tavolo}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
              subtitle: Text('${ordine.pietanze.length} pietanze - ${ordine.statoComplessivo}', 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: Text('€${ordine.totale.toStringAsFixed(2)}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            )),
            if (ordiniAttivi > 2)
              Center(
                child: Text('...e altri ${ordiniAttivi - 2} ordini',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}