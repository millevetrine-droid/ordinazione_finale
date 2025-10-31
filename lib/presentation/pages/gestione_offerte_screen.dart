import 'package:flutter/material.dart';
import 'gestione_offerte_controller.dart';
import 'gestione_offerte_dialog.dart';
import 'gestione_offerte_widgets.dart';
import 'package:ordinazione/core/services/menu_services/menu_service.dart';

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
    // Delay loading until after the first frame so `ScaffoldMessenger.of(context)`
    // can safely be used inside `_caricaDati` (avoids dependOnInheritedWidgetOfExactType
    // called before initState completed).
    WidgetsBinding.instance.addPostFrameCallback((_) => _caricaDati());
  }

  void _caricaDati() async {
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

    // Optimistic local update so the owner sees the new offer immediately
    _controller.aggiungiOffertaLocale(nuovaOfferta);
    if (mounted) setState(() {});

    // Also update the global MenuService cache and notify listeners so the
    // public OffertePage (which listens to MenuService().offerteStream)
    // receives the new offer immediately even if the remote write fails.
    try {
      MenuService().aggiornaOffertaLocaleEAvvisa(nuovaOfferta);
    } catch (e) {
      // Non-fatal; we still attempt the remote save below.
      debugPrint('⚠️ Could not notify MenuService cache: $e');
    }

    try {
      await _controller.salvaOfferta(nuovaOfferta);
      if (!mounted) return;
      _caricaDati();
      scaffold.showSnackBar(
        const SnackBar(content: Text('✅ Offerta salvata con successo!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      // Remote save failed — leave local optimistic entry visible but warn the user.
      scaffold.showSnackBar(
        SnackBar(content: Text('⚠️ Offerta salvata localmente, sincronizzazione remota fallita: $e'), backgroundColor: Colors.orange),
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
        backgroundColor: Colors.pink[700],
        foregroundColor: Colors.white,
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
      backgroundColor: Colors.grey[50],
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
