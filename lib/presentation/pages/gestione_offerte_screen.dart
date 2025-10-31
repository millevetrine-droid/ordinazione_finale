import 'package:flutter/material.dart';
import 'gestione_offerte_controller.dart';
import 'gestione_offerte_dialog.dart';
import 'gestione_offerte_widgets.dart';

class GestioneOfferteScreen extends StatefulWidget {
  const GestioneOfferteScreen({super.key});

  @override
  State<GestioneOfferteScreen> createState() => _GestioneOfferteScreenState();
}

class _GestioneOfferteScreenState extends State<GestioneOfferteScreen> {
  final GestioneOfferteController _controller = GestioneOfferteController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Delay data load until after the first frame so that `context` can be
    // used safely (ScaffoldMessenger.of(context) etc.). This avoids the
    // dependOnInheritedWidgetOfExactType(...) called before initState error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaDati();
    });
  }

  void _caricaDati() async {
    // Acquire messenger only when needed and after the frame has been drawn.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _controller.caricaDati();
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      GestioneOfferteWidgets.mostraMessaggioWithMessenger(messenger, '❌ Errore caricamento: $e');
      setState(() => _isLoading = false);
    }
  }

  void _mostraDialogOfferta([Map<String, dynamic>? offertaEsistente]) {
    GestioneOfferteDialog.mostra(
      context: context,
      controller: _controller,
      offertaEsistente: offertaEsistente,
      onSalva: _salvaOfferta,
    );
  }

  void _salvaOfferta(
    String titolo,
    String sottotitolo,
    double prezzo,
    String immagine,
    String linkTipo,
    String linkDestinazione,
    String? idEsistente,
  ) async {
    if (titolo.isEmpty || sottotitolo.isEmpty || prezzo <= 0 || immagine.isEmpty) {
      GestioneOfferteWidgets.mostraMessaggio(context, 'Compila tutti i campi obbligatori');
      return;
    }

    if (linkTipo != 'ordina' && linkDestinazione.isEmpty) {
      GestioneOfferteWidgets.mostraMessaggio(context, 'Seleziona una destinazione');
      return;
    }

    final scaffold = ScaffoldMessenger.of(context);

    try {
      final nuovaOfferta = {
        'id': idEsistente ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'titolo': titolo,
        'sottotitolo': sottotitolo,
        'prezzo': prezzo,
        'immagine': immagine,
        'colore': '#ffff6b8b',
        'linkTipo': linkTipo,
        'linkDestinazione': linkDestinazione,
        'attiva': true,
        'ordine': _controller.offerte.length,
      };

      await _controller.salvaOfferta(nuovaOfferta);
      if (!mounted) return;
      _caricaDati();
      scaffold.showSnackBar(
        const SnackBar(content: Text('✅ Offerta salvata con successo!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      scaffold.showSnackBar(
        SnackBar(content: Text('❌ Errore nel salvataggio: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _eliminaOfferta(String idOfferta) async {
    final conferma = await GestioneOfferteWidgets.mostraConfermaElimina(context);
    if (conferma) {
      try {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        await _controller.eliminaOfferta(idOfferta);
        if (!mounted) return;
        _caricaDati();
        messenger.showSnackBar(
          const SnackBar(content: Text('✅ Offerta eliminata'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('❌ Errore eliminazione: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _cambiaStatoOfferta(int index, bool nuovoStato) async {
    try {
      final offerta = Map<String, dynamic>.from(_controller.offerte[index]);
      offerta['attiva'] = nuovoStato;
      final scaffold = ScaffoldMessenger.of(context);
      await _controller.salvaOfferta(offerta);
      if (!mounted) return;
      _caricaDati();
      scaffold.showSnackBar(
        SnackBar(
          content: Text(nuovoStato ? '✅ Offerta attivata' : '⏸️ Offerta disattivata'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(content: Text('❌ Errore modifica stato: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 GESTIONE OFFERTE'),
        // Use theme colors so the AppBar matches the rest of the app UI.
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _mostraDialogOfferta(),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.offerte.isEmpty
              ? const Center(
                  child: Text(
                    'Nessuna offerta creata\n\nTocca ➕ per aggiungere la prima offerta!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _controller.offerte.length,
                  itemBuilder: (context, index) {
                    final offerta = _controller.offerte[index];
                    return GestioneOfferteWidgets.buildOffertaCard(
                      offerta: offerta,
                      controller: _controller,
                      onModifica: () => _mostraDialogOfferta(offerta),
                      onElimina: () => _eliminaOfferta(offerta['id']),
                      onCambiaStato: () => _cambiaStatoOfferta(index, !(offerta['attiva'] == true)),
                    );
                  },
                ),
    );
  }
}
