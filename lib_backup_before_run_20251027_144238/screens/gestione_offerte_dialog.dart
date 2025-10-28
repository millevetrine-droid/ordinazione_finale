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
    String linkTipo,
    String linkDestinazione,
    GestioneOfferteController controller,
    Function(String?) onChanged,
  ) {
    if (linkTipo == 'categoria') {
      return DropdownButtonFormField<String>(
        initialValue: linkDestinazione.isEmpty ? null : linkDestinazione,
        decoration: const InputDecoration(labelText: 'Seleziona Categoria'),
        items: controller.categorie.map<DropdownMenuItem<String>>((categoria) {
          return DropdownMenuItem<String>(
            value: categoria['id'],
            child: Text('${categoria['nome']}'),
          );
        }).toList(),
        onChanged: onChanged,
      );
    } else if (linkTipo == 'pietanza') {
      return DropdownButtonFormField<String>(
        initialValue: linkDestinazione.isEmpty ? null : linkDestinazione,
        decoration: const InputDecoration(labelText: 'Seleziona Pietanza'),
        items: controller.pietanze.map<DropdownMenuItem<String>>((pietanza) {
          return DropdownMenuItem<String>(
            value: pietanza['id'],
            child: Text('${pietanza['nome']} (${pietanza['categoria']})'),
          );
        }).toList(),
        onChanged: onChanged,
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