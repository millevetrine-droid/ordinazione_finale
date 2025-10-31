import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/session_provider.dart';
import 'selezione_tavolo_dialog.dart';

class QrTavoloDialog extends StatefulWidget {
  final String? sessionInfo;

  const QrTavoloDialog({
    super.key,
    this.sessionInfo,
  });

  @override
  State<QrTavoloDialog> createState() => _QrTavoloDialogState();
}

class _QrTavoloDialogState extends State<QrTavoloDialog> {
  @override
  Widget build(BuildContext context) {
    // Leggi la sessione corrente dal provider, preferendo il valore passato se fornito
    final sessionProvider = Provider.of<SessionProvider>(context);
    final s = sessionProvider.sessioneCorrente;
    final info = (widget.sessionInfo != null && widget.sessionInfo!.isNotEmpty)
        ? widget.sessionInfo
        : (s != null ? 'Tavolo: ${s.numeroTavolo}' : null);

    // Debug: log del session info
    // ignore: avoid_print
    debugPrint('QR DIALOG - sessionInfo passed: ${widget.sessionInfo} - resolved: $info');

    return AlertDialog(
      backgroundColor: Colors.black.withAlpha(230),
      title: const Text(
        'QR Code Tavolo',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white70),
            ),
            child: Center(
              child: info != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code, size: 56, color: Colors.black54),
                        const SizedBox(height: 8),
                        Text(
                          info,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : const Text(
                      'Nessuna sessione attiva',
                      style: TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            info ?? 'Seleziona un tavolo per generare il QR',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        if (s == null) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8B),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final numeroTavolo = await showDialog<String>(
                context: context,
                builder: (context) => SelezioneTavoloDialog(
                  onTavoloSelezionato: (numero) {
                    Navigator.of(context).pop(numero);
                  },
                ),
              );

              if (!context.mounted) return;

              if (numeroTavolo != null) {
                final numero = int.tryParse(numeroTavolo);
                if (numero != null) {
                  Provider.of<SessionProvider>(context, listen: false).setTavolo(numero);
                  // Chiudi questo dialog e riaprilo per aggiornare la view
                  Navigator.of(context).pop();
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => const QrTavoloDialog(),
                  );
                }
              }
            },
            child: const Text('Seleziona Tavolo'),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CHIUDI', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}


