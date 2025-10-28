import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/ordini_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/ordine_model.dart';
import '../../../../core/models/pietanza_model.dart';
import 'pietanza_row.dart';
import 'action_buttons.dart';

class OrdineCard extends StatelessWidget {
  final Ordine ordine;

  const OrdineCard({super.key, required this.ordine});

  @override
  Widget build(BuildContext context) {
    // ✅ CORRETTO: Nascondi ordine solo quando TUTTE le pietanze sono pronte o servite
    final haPietanzeDaPreparare = ordine.pietanze.any((p) => !p.isPronto && !p.isServito);
    if (!haPietanzeDaPreparare) {
      return const SizedBox.shrink();
    }

    // ✅ CORRETTO: Mostra solo pietanze NON PRONTE e NON SERVIRE (quelle da preparare)
    final pietanzeDaMostrare = ordine.pietanze.where((p) => !p.isPronto && !p.isServito).toList();
    
    final conteggioStati = _calcolaConteggioStatiPietanze(pietanzeDaMostrare);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColoreStato(ordine.stato).withAlpha((0.5 * 255).round())),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildRiepilogoStati(conteggioStati, pietanzeDaMostrare.length),
            const SizedBox(height: 12),
            _buildPietanzeList(pietanzeDaMostrare, context),
            if (ordine.note.isNotEmpty) _buildNote(),
            const SizedBox(height: 12),
            _buildTimestamp(),
            const SizedBox(height: 12),
            if (ordine.stato == StatoOrdine.inAttesa) _buildAzioneButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.table_restaurant, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tavolo ${ordine.numeroTavolo}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getColoreStato(ordine.stato).withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getColoreStato(ordine.stato)),
          ),
          child: Text(
            _getStatoTesto(ordine.stato).toUpperCase(),
            style: TextStyle(
              color: _getColoreStato(ordine.stato),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiepilogoStati(Map<String, int> conteggio, int totalePietanze) {
    return Container(
      padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatoIndicator('In Attesa', Colors.orange, conteggio['inAttesa'] ?? 0),
          _buildStatoIndicator('In Prep.', Colors.blue, conteggio['inPreparazione'] ?? 0),
          _buildStatoIndicator('Da Fare', Colors.white, totalePietanze),
        ],
      ),
    );
  }

  Widget _buildStatoIndicator(String label, Color color, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPietanzeList(List<Pietanza> pietanze, BuildContext context) {
    return Column(
      children: pietanze.map((pietanza) => PietanzaRow(
        pietanza: pietanza,
        ordine: ordine,
        onAzionePressed: ({
          required Ordine ordine,
          required Pietanza pietanza,
          required StatoPietanza nuovoStato,
        }) => _onAzionePietanza(
          ordine: ordine,
          pietanza: pietanza,
          nuovoStato: nuovoStato,
          context: context,
        ),
      )).toList(),
    );
  }

  Widget _buildNote() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
                  color: Colors.orange.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.withAlpha((0.3 * 255).round())),
                ),
          child: Row(
            children: [
              const Icon(Icons.note, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ordine.note,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp() {
    return Text(
      'Ordine: ${_formatTime(ordine.timestamp)}',
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
      ),
    );
  }

  Widget _buildAzioneButton(BuildContext context) {
    return ActionButtons.buildAzioneButton(
      'INIZIA TUTTE LE PREPARAZIONI',
      Colors.blue,
      () => _cambiaStatoOrdine(ordine, StatoOrdine.inPreparazione, context),
    );
  }

  void _onAzionePietanza({
    required Ordine ordine,
    required Pietanza pietanza,
    required StatoPietanza nuovoStato,
    required BuildContext context,
  }) {
    final ordiniProvider = Provider.of<OrdiniProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    ordiniProvider.aggiornaStatoPietanza(
      ordineId: ordine.id,
      pietanzaId: pietanza.id,
      nuovoStato: nuovoStato,
      user: authProvider.user!.username,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pietanza.nome} ${_getStatoPietanzaTesto(nuovoStato)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cambiaStatoOrdine(Ordine ordine, StatoOrdine nuovoStato, BuildContext context) {
    final ordiniProvider = Provider.of<OrdiniProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    ordiniProvider.aggiornaStatoOrdine(ordine.id, nuovoStato, authProvider.user!.username);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ordine ${ordine.numeroTavolo} ${_getStatoTesto(nuovoStato)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Map<String, int> _calcolaConteggioStatiPietanze(List<Pietanza> pietanze) {
    // ✅ CORRETTO: Conta solo pietanze NON PRONTE (quelle ancora visibili)
    final inAttesa = pietanze.where((p) => p.isInAttesa).length;
    final inPreparazione = pietanze.where((p) => p.isInPreparazione).length;

    return {
      'inAttesa': inAttesa,
      'inPreparazione': inPreparazione,
      // ❌ NON mostriamo più il conteggio "pronte" perché non sono visibili
    };
  }

  String _getStatoTesto(StatoOrdine stato) {
    return switch (stato) {
      StatoOrdine.inAttesa => 'in attesa',
      StatoOrdine.inPreparazione => 'in preparazione',
      StatoOrdine.pronto => 'pronto',
      StatoOrdine.servito => 'servito',
      StatoOrdine.completato => 'completato',
    }; // ✅ AGGIUNTO PUNTO E VIRGOLA
  }

  String _getStatoPietanzaTesto(StatoPietanza stato) {
    return switch (stato) {
      StatoPietanza.inAttesa => 'in attesa',
      StatoPietanza.inPreparazione => 'in preparazione',
      StatoPietanza.pronto => 'pronto',
      StatoPietanza.servito => 'servito',
    }; // ✅ AGGIUNTO PUNTO E VIRGOLA
  }

  Color _getColoreStato(StatoOrdine stato) {
    return switch (stato) {
      StatoOrdine.inAttesa => Colors.orange,
      StatoOrdine.inPreparazione => Colors.blue,
      StatoOrdine.pronto => Colors.green,
      StatoOrdine.servito => Colors.purple,
      StatoOrdine.completato => Colors.grey,
    }; // ✅ AGGIUNTO PUNTO E VIRGOLA
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}