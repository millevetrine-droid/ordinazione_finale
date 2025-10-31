import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'gestione_offerte_controller.dart';

/// Widget-based dialog for gestione offerte.
/// Converted from the older static helper to a StatefulWidget so that
/// dropdowns and input styling behave reliably inside the dialog and
/// we can guard setState/dispose properly.
class GestioneOfferteDialogWidget extends StatefulWidget {
  final GestioneOfferteController controller;
  final Map<String, dynamic>? offertaEsistente;
  final void Function(
    String titolo,
    String sottotitolo,
    double prezzo,
    String immagine,
    String linkTipo,
    String linkDestinazione,
    String? idEsistente,
  ) onSalva;

  const GestioneOfferteDialogWidget({
    super.key,
    required this.controller,
    this.offertaEsistente,
    required this.onSalva,
  });

  static Future<void> mostra({
    required BuildContext context,
    required GestioneOfferteController controller,
    Map<String, dynamic>? offertaEsistente,
    required Function onSalva,
  }) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: GestioneOfferteDialogWidget(
          controller: controller,
          offertaEsistente: offertaEsistente,
          onSalva: (
            String titolo,
            String sottotitolo,
            double prezzo,
            String immagine,
            String linkTipo,
            String linkDestinazione,
            String? idEsistente,
          ) {
            onSalva(
              titolo,
              sottotitolo,
              prezzo,
              immagine,
              linkTipo,
              linkDestinazione,
              idEsistente,
            );
          },
        ),
      ),
    );
  }

  @override
  State<GestioneOfferteDialogWidget> createState() => _GestioneOfferteDialogWidgetState();
}

class _GestioneOfferteDialogWidgetState extends State<GestioneOfferteDialogWidget> {
  late final TextEditingController _titoloController;
  late final TextEditingController _sottotitoloController;
  late final TextEditingController _prezzoController;
  late final TextEditingController _immagineController;

  late String _linkTipoSelezionato;
  late String _linkDestinazioneSelezionata;
  bool get isModifica => widget.offertaEsistente != null;

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.offertaEsistente?['titolo'] ?? '');
    _sottotitoloController = TextEditingController(text: widget.offertaEsistente?['sottotitolo'] ?? '');
    _prezzoController = TextEditingController(text: widget.offertaEsistente?['prezzo']?.toString() ?? '');
    _immagineController = TextEditingController(text: widget.offertaEsistente?['immagine'] ?? 'ðŸ•');

    _linkTipoSelezionato = widget.offertaEsistente?['linkTipo'] ?? 'categoria';
    _linkDestinazioneSelezionata = widget.offertaEsistente?['linkDestinazione'] ?? '';

    // Defensive: ensure controller has loaded data; try to load if empty
    if (widget.controller.categorie.isEmpty || widget.controller.pietanze.isEmpty) {
      widget.controller.caricaDati().then((_) {
        if (!mounted) return;
        setState(() {});
        if (widget.controller.categorie.isEmpty || widget.controller.pietanze.isEmpty) {
          dev.log('GestioneOfferteDialog: categorie/pietanze ancora vuote dopo caricaDati()', name: 'GestioneOfferteDialog');
        }
      }).catchError((e) {
        dev.log('Errore caricaDati() nel dialog: $e', name: 'GestioneOfferteDialog');
      });
    }
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _sottotitoloController.dispose();
    _prezzoController.dispose();
    _immagineController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: const TextStyle(color: Colors.black45),
      filled: true,
      fillColor: Colors.white,
    );
  }

  TextStyle _textStyle() => const TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    // Force a light-inner theme for the dialog inputs so text is visible
    return Theme(
      data: ThemeData.light().copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black87),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isModifica ? 'âœï¸ Modifica Offerta' : 'âž• Nuova Offerta', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              // Visible debug panel to help verify at runtime which code is running
              // and whether controller loaded categories/pietanze. Remove in final PR.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent),
                  color: Colors.white70,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEBUG: categorie=${widget.controller.categorie.length}, pietanze=${widget.controller.pietanze.length}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        'Categorie: ${widget.controller.categorie.map((c) => c['nome']?.toString() ?? c['id']?.toString() ?? '(?)').join(', ')}',
                        style: const TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _titoloController,
                style: _textStyle(),
                decoration: _inputDecoration('Titolo offerta *', 'Es: ðŸ” MENU DEL GIORNO'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sottotitoloController,
                style: _textStyle(),
                decoration: _inputDecoration('Descrizione *', 'Es: Panino + Patatine + Bibita'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _prezzoController,
                style: _textStyle(),
                decoration: _inputDecoration('Prezzo (â‚¬) *', 'Es: 12.90'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _immagineController,
                style: _textStyle(),
                decoration: _inputDecoration('Emoji *', 'Es: ðŸ” (usa tastiera emoji)'),
              ),
              const SizedBox(height: 12),

              // Tipo link
              DropdownButtonFormField<String>(
                initialValue: _linkTipoSelezionato,
                decoration: _inputDecoration('Quando cliccano, vai a:'),
                isExpanded: true,
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                items: const [
                  DropdownMenuItem<String>(value: 'categoria', child: Text('ðŸ“‚ Una Categoria')),
                  DropdownMenuItem<String>(value: 'pietanza', child: Text('ðŸ½ï¸ Una Pietanza')),
                  DropdownMenuItem<String>(value: 'ordina', child: Text("ðŸ›’ Direttamente all'ordine")),
                ],
                onChanged: (val) {
                  final nuovo = val ?? 'categoria';
                  dev.log('TipoLink cambiato: $nuovo', name: 'GestioneOfferteDialog');
                  setState(() {
                    _linkTipoSelezionato = nuovo;
                    _linkDestinazioneSelezionata = '';
                  });
                },
              ),

              const SizedBox(height: 10),

              // Destinazione dropdown (categoria / pietanza)
              _buildDestinazioneWidget(),

              const SizedBox(height: 10),
              const Text('* Campi obbligatori\nUsa la tastiera del telefono per le emoji', style: TextStyle(fontSize: 12, color: Colors.grey)),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULLA')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSalva(
                        _titoloController.text,
                        _sottotitoloController.text,
                        double.tryParse(_prezzoController.text) ?? 0.0,
                        _immagineController.text,
                        _linkTipoSelezionato,
                        _linkDestinazioneSelezionata,
                        widget.offertaEsistente?['id'],
                      );
                      Navigator.pop(context);
                    },
                    child: Text(isModifica ? 'MODIFICA' : 'SALVA'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinazioneWidget() {
    if (_linkTipoSelezionato == 'categoria') {
      if (widget.controller.categorie.isEmpty) {
        return const Text('Nessuna categoria disponibile', style: TextStyle(color: Colors.grey));
      }
      return DropdownButtonFormField<String>(
        initialValue: _linkDestinazioneSelezionata.isEmpty ? null : _linkDestinazioneSelezionata,
        decoration: _inputDecoration('Seleziona Categoria'),
        isExpanded: true,
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.black,
        items: widget.controller.categorie.map<DropdownMenuItem<String>>((categoria) {
          final id = categoria['id']?.toString() ?? '';
          final nome = categoria['nome']?.toString() ?? id;
          return DropdownMenuItem<String>(value: id, child: Text(nome, style: _textStyle()));
        }).toList(),
        onChanged: (val) {
          dev.log('Categoria selezionata: $val', name: 'GestioneOfferteDialog');
          setState(() {
            _linkDestinazioneSelezionata = val ?? '';
          });
        },
      );
    } else if (_linkTipoSelezionato == \'pietanza\') {
  if (widget.controller.pietanze.isEmpty) {
    return const Text(\'Nessuna pietanza disponibile\', style: TextStyle(color: Colors.grey));
  }

  // Selezione alternativa: campo tappabile che apre un modal bottom sheet con lista
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Seleziona Pietanza', style: TextStyle(fontSize: 12, color: Colors.black54)),
      SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final selected = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) {
              return SafeArea(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.controller.pietanze.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = widget.controller.pietanze[i];
                    final id = p['id']?.toString() ?? '';
                    final nome = p['nome']?.toString() ?? id;
                    final cat = p['categoria']?.toString() ?? '';
                    return ListTile(
                      title: Text('$nome ($cat)', style: _textStyle()),
                      onTap: () => Navigator.of(ctx).pop(id),
                    );
                  },
                ),
              );
            },
          );
          if (selected != null) {
            setState(() {
              _linkDestinazioneSelezionata = selected;
            });
            dev.log('Pietanza selezionata (sheet): $selected', name: 'GestioneOfferteDialog');
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Builder(builder: (context) {
                  final sel = _linkDestinazioneSelezionata;
                  final found = widget.controller.pietanze.firstWhere(
                    (p) => (p['id']?.toString() ?? '') == sel,
                    orElse: () => null,
                  );
                  final label = found != null ? (found['nome']?.toString() ?? sel) : 'Seleziona Pietanza';
                  return Text(label, style: _textStyle());
                }),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    ],
  );
}

class _GestioneOfferteDialogWidgetState extends State<GestioneOfferteDialogWidget> {
  late final TextEditingController _titoloController;
  late final TextEditingController _sottotitoloController;
  late final TextEditingController _prezzoController;
  late final TextEditingController _immagineController;

  late String _linkTipoSelezionato;
  late String _linkDestinazioneSelezionata;
  bool get isModifica => widget.offertaEsistente != null;

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.offertaEsistente?['titolo'] ?? '');
    _sottotitoloController = TextEditingController(text: widget.offertaEsistente?['sottotitolo'] ?? '');
    _prezzoController = TextEditingController(text: widget.offertaEsistente?['prezzo']?.toString() ?? '');
    _immagineController = TextEditingController(text: widget.offertaEsistente?['immagine'] ?? 'ðŸ•');

    _linkTipoSelezionato = widget.offertaEsistente?['linkTipo'] ?? 'categoria';
    _linkDestinazioneSelezionata = widget.offertaEsistente?['linkDestinazione'] ?? '';

    // Defensive: ensure controller has loaded data; try to load if empty
    if (widget.controller.categorie.isEmpty || widget.controller.pietanze.isEmpty) {
      widget.controller.caricaDati().then((_) {
        if (!mounted) return;
        setState(() {});
        if (widget.controller.categorie.isEmpty || widget.controller.pietanze.isEmpty) {
          dev.log('GestioneOfferteDialog: categorie/pietanze ancora vuote dopo caricaDati()', name: 'GestioneOfferteDialog');
        }
      }).catchError((e) {
        dev.log('Errore caricaDati() nel dialog: $e', name: 'GestioneOfferteDialog');
      });
    }
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _sottotitoloController.dispose();
    _prezzoController.dispose();
    _immagineController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: const TextStyle(color: Colors.black45),
      filled: true,
      fillColor: Colors.white,
    );
  }

  TextStyle _textStyle() => const TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    // Force a light-inner theme for the dialog inputs so text is visible
    return Theme(
      data: ThemeData.light().copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black87),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isModifica ? 'âœï¸ Modifica Offerta' : 'âž• Nuova Offerta', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              // Visible debug panel to help verify at runtime which code is running
              // and whether controller loaded categories/pietanze. Remove in final PR.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent),
                  color: Colors.white70,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEBUG: categorie=${widget.controller.categorie.length}, pietanze=${widget.controller.pietanze.length}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        'Categorie: ${widget.controller.categorie.map((c) => c['nome']?.toString() ?? c['id']?.toString() ?? '(?)').join(', ')}',
                        style: const TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _titoloController,
                style: _textStyle(),
                decoration: _inputDecoration('Titolo offerta *', 'Es: ðŸ” MENU DEL GIORNO'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sottotitoloController,
                style: _textStyle(),
                decoration: _inputDecoration('Descrizione *', 'Es: Panino + Patatine + Bibita'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _prezzoController,
                style: _textStyle(),
                decoration: _inputDecoration('Prezzo (â‚¬) *', 'Es: 12.90'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _immagineController,
                style: _textStyle(),
                decoration: _inputDecoration('Emoji *', 'Es: ðŸ” (usa tastiera emoji)'),
              ),
              const SizedBox(height: 12),

              // Tipo link
              DropdownButtonFormField<String>(
                initialValue: _linkTipoSelezionato,
                decoration: _inputDecoration('Quando cliccano, vai a:'),
                isExpanded: true,
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                items: const [
                  DropdownMenuItem<String>(value: 'categoria', child: Text('ðŸ“‚ Una Categoria')),
                  DropdownMenuItem<String>(value: 'pietanza', child: Text('ðŸ½ï¸ Una Pietanza')),
                  DropdownMenuItem<String>(value: 'ordina', child: Text("ðŸ›’ Direttamente all'ordine")),
                ],
                onChanged: (val) {
                  final nuovo = val ?? 'categoria';
                  dev.log('TipoLink cambiato: $nuovo', name: 'GestioneOfferteDialog');
                  setState(() {
                    _linkTipoSelezionato = nuovo;
                    _linkDestinazioneSelezionata = '';
                  });
                },
              ),

              const SizedBox(height: 10),

              // Destinazione dropdown (categoria / pietanza)
              _buildDestinazioneWidget(),

              const SizedBox(height: 10),
              const Text('* Campi obbligatori\nUsa la tastiera del telefono per le emoji', style: TextStyle(fontSize: 12, color: Colors.grey)),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULLA')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSalva(
                        _titoloController.text,
                        _sottotitoloController.text,
                        double.tryParse(_prezzoController.text) ?? 0.0,
                        _immagineController.text,
                        _linkTipoSelezionato,
                        _linkDestinazioneSelezionata,
                        widget.offertaEsistente?['id'],
                      );
                      Navigator.pop(context);
                    },
                    child: Text(isModifica ? 'MODIFICA' : 'SALVA'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinazioneWidget() {
    if (_linkTipoSelezionato == 'categoria') {
      if (widget.controller.categorie.isEmpty) {
        return const Text('Nessuna categoria disponibile', style: TextStyle(color: Colors.grey));
      }
      return DropdownButtonFormField<String>(
        initialValue: _linkDestinazioneSelezionata.isEmpty ? null : _linkDestinazioneSelezionata,
        decoration: _inputDecoration('Seleziona Categoria'),
        isExpanded: true,
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.black,
        items: widget.controller.categorie.map<DropdownMenuItem<String>>((categoria) {
          final id = categoria['id']?.toString() ?? '';
          final nome = categoria['nome']?.toString() ?? id;
          return DropdownMenuItem<String>(value: id, child: Text(nome, style: _textStyle()));
        }).toList(),
        onChanged: (val) {
          dev.log('Categoria selezionata: $val', name: 'GestioneOfferteDialog');
          setState(() {
            _linkDestinazioneSelezionata = val ?? '';
          });
        },
      );
    } else if (_linkTipoSelezionato == \'pietanza\') {
  if (widget.controller.pietanze.isEmpty) {
    return const Text(\'Nessuna pietanza disponibile\', style: TextStyle(color: Colors.grey));
  }

  // Selezione alternativa: campo tappabile che apre un modal bottom sheet con lista
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Seleziona Pietanza', style: TextStyle(fontSize: 12, color: Colors.black54)),
      SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final selected = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) {
              return SafeArea(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.controller.pietanze.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = widget.controller.pietanze[i];
                    final id = p['id']?.toString() ?? '';
                    final nome = p['nome']?.toString() ?? id;
                    final cat = p['categoria']?.toString() ?? '';
                    return ListTile(
                      title: Text('$nome ($cat)', style: _textStyle()),
                      onTap: () => Navigator.of(ctx).pop(id),
                    );
                  },
                ),
              );
            },
          );
          if (selected != null) {
            setState(() {
              _linkDestinazioneSelezionata = selected;
            });
            dev.log('Pietanza selezionata (sheet): $selected', name: 'GestioneOfferteDialog');
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Builder(builder: (context) {
                  final sel = _linkDestinazioneSelezionata;
                  final found = widget.controller.pietanze.firstWhere(
                    (p) => (p['id']?.toString() ?? '') == sel,
                    orElse: () => null,
                  );
                  final label = found != null ? (found['nome']?.toString() ?? sel) : 'Seleziona Pietanza';
                  return Text(label, style: _textStyle());
                }),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    ],
  );
} else if (_linkTipoSelezionato == 'ordina') {
      return const Text("L'utente andrÃ  direttamente alla schermata ordini", style: TextStyle(color: Colors.grey, fontSize: 12));
    }
    return const SizedBox();
  }
}


