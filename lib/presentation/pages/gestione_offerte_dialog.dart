import 'package:flutter/material.dart';
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
    final immagineController = TextEditingController(text: offertaEsistente?['immagine'] ?? '🍕');
    
    String linkTipoSelezionato = offertaEsistente?['linkTipo'] ?? 'categoria';
    String linkDestinazioneSelezionata = offertaEsistente?['linkDestinazione'] ?? '';

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
            linkTipoSelezionato: linkTipoSelezionato,
            linkDestinazioneSelezionata: linkDestinazioneSelezionata,
            controller: controller,
            setDialogState: setDialogState,
            onSalva: () => onSalva(
              titoloController.text,
              sottotitoloController.text,
              double.tryParse(prezzoController.text) ?? 0.0,
              immagineController.text,
              linkTipoSelezionato,
              linkDestinazioneSelezionata,
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
    required String linkTipoSelezionato,
    required String linkDestinazioneSelezionata,
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
              decoration: const InputDecoration(
                labelText: 'Titolo offerta *',
                hintText: 'Es: 🍔 MENU DEL GIORNO',
              ),
            ),
            TextField(
              controller: sottotitoloController,
              decoration: const InputDecoration(
                labelText: 'Descrizione *',
                hintText: 'Es: Panino + Patatine + Bibita',
              ),
            ),
            TextField(
              controller: prezzoController,
              decoration: const InputDecoration(
                labelText: 'Prezzo (€) *',
                hintText: 'Es: 12.90',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: immagineController,
              decoration: const InputDecoration(
                labelText: 'Emoji *',
                hintText: 'Es: 🍔 (usa tastiera emoji)',
              ),
            ),
            
            _buildTipoLinkDropdown(
              linkTipoSelezionato,
              (value) => setDialogState(() {
                linkTipoSelezionato = value ?? 'categoria';
                linkDestinazioneSelezionata = '';
              }),
            ),
            
            const SizedBox(height: 10),
            _buildDestinazioneDropdown(
              context,
              linkTipoSelezionato,
              linkDestinazioneSelezionata,
              controller,
              (value) => setDialogState(() {
                linkDestinazioneSelezionata = value ?? '';
              }),
            ),
            
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
            onSalva();
            Navigator.pop(context);
          },
          child: Text(isModifica ? 'MODIFICA' : 'SALVA'),
        ),
      ],
    );
  }

  static Widget _buildTipoLinkDropdown(String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Quando cliccano, vai a:'),
      items: const [
        DropdownMenuItem<String>(value: 'categoria', child: Text('📂 Una Categoria')),
        DropdownMenuItem<String>(value: 'pietanza', child: Text('🍽️ Una Pietanza')),
        DropdownMenuItem<String>(value: 'ordina', child: Text('🛒 Direttamente all\'ordine')),
      ],
      onChanged: onChanged,
    );
  }

  static Widget _buildDestinazioneDropdown(
    BuildContext context,
    String linkTipo,
    String linkDestinazione,
    GestioneOfferteController controller,
    Function(String?) onChanged,
  ) {
    // Use a modal selection sheet instead of the DropdownButtonFormField inside
    // an AlertDialog. This avoids issues where the dropdown menu doesn't open
    // reliably inside dialogs on some platforms.
    if (linkTipo == 'categoria') {
      return InkWell(
        onTap: () async {
          final result = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) {
              final items = controller.categorie;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nessuna categoria disponibile', style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx2, i) {
                  final categoria = items[i];
                  return ListTile(
                    title: Text('${categoria['nome']}'),
                    onTap: () => Navigator.of(ctx).pop(categoria['id'] as String),
                  );
                },
              );
            },
          );
          if (result != null) onChanged(result);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Seleziona Categoria'),
          child: Text(linkDestinazione.isEmpty
              ? 'Tocca per selezionare...'
              : (controller.categorie.firstWhere((c) => c['id'] == linkDestinazione, orElse: () => {'nome': '—'})['nome'])),
        ),
      );
    } else if (linkTipo == 'pietanza') {
      return InkWell(
        onTap: () async {
          final result = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) {
              final items = controller.pietanze;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nessuna pietanza disponibile', style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx2, i) {
                  final pietanza = items[i];
                  return ListTile(
                    title: Text('${pietanza['nome']} (${pietanza['categoria']})'),
                    onTap: () => Navigator.of(ctx).pop(pietanza['id'] as String),
                  );
                },
              );
            },
          );
          if (result != null) onChanged(result);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Seleziona Pietanza'),
          child: Text(linkDestinazione.isEmpty
              ? 'Tocca per selezionare...'
              : (controller.pietanze.firstWhere((p) => p['id'] == linkDestinazione, orElse: () => {'nome': '—'})['nome'])),
        ),
      );
    } else if (linkTipo == 'ordina') {
      return const Text(
        'L\'utente andrà direttamente alla schermata ordini',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }

    return const SizedBox();
  }
}
