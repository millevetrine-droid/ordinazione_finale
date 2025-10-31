/// FILE: lib/features/home/dialogs/selezione_tavolo_dialog.dart
/// SCOPO: Dialog per selezione tavolo di prova
/// 
/// MODIFICHE APPLICATE:
/// - 2024-01-20 - Modificati pulsanti per ritornare valore invece di chiamare callback
library;
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ordinazione/core/services/session_service.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/session_provider.dart';

class SelezioneTavoloDialog extends StatefulWidget {
  final Function(String) onTavoloSelezionato;

  const SelezioneTavoloDialog({
    super.key,
    required this.onTavoloSelezionato,
  });

  static void show({
    required BuildContext context,
    required Function(String) onTavoloSelezionato,
  }) {
    showDialog(
      context: context,
      builder: (context) => SelezioneTavoloDialog(
        onTavoloSelezionato: onTavoloSelezionato,
      ),
    );
  }

  @override
  State<SelezioneTavoloDialog> createState() => _SelezioneTavoloDialogState();
}

class _SelezioneTavoloDialogState extends State<SelezioneTavoloDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('🎯 Seleziona Tavolo di Prova'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Scegli un numero di tavolo per testare l\'app:'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [1, 2, 3, 4].map((numero) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(numero.toString());
                },
                child: Text('Tavolo $numero'),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Oppure incolla qui il codice QR:'),
          const SizedBox(height: 8),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              hintText: 'Codice sessione',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed('/qr_scanner');
              if (result != null && result is String) {
                if (mounted) Navigator.of(context).pop(result);
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Apri scanner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () async {
            final code = _codeController.text.trim();
            if (code.isEmpty) return;
            setState(() { _isLoading = true; });
              try {
              final s = await SessionService().joinSessionByCode(code);
              if (s != null) {
                if (!mounted) return;
                // update provider and start listening to session changes
                final prov = Provider.of<SessionProvider>(context, listen: false);
                prov.setTavolo(s.numeroTavolo);
                prov.listenToSession(s.sessionId);
                Navigator.of(context).pop(s.numeroTavolo.toString());
                return;
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sessione non trovata o scaduta'), backgroundColor: Colors.orange));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red));
              }
            } finally {
              if (mounted) setState(() { _isLoading = false; });
            }
          },
          child: _isLoading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator()) : const Text('Unisciti alla sessione'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
      ],
    );
  }
}