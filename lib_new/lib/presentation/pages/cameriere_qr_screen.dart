import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ordinazione/core/providers/auth_provider.dart';
import 'package:ordinazione/core/providers/session_provider.dart';
import 'package:ordinazione/core/services/qr_generator_service.dart';

class CameriereQrScreen extends StatefulWidget {
  const CameriereQrScreen({super.key});

  @override
  State<CameriereQrScreen> createState() => _CameriereQrScreenState();
}

class _CameriereQrScreenState extends State<CameriereQrScreen> {
  final List<int> _tavoliDisponibili = List.generate(20, (index) => index + 1);
  int? _tavoloSelezionato;
  String? _qrData;
  String? _codiceSessione;

  void _generaQrCode() {
    if (_tavoloSelezionato == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    // CORREZIONE: Usa i metodi corretti di QrGeneratorService
    final sessione = QrGeneratorService.creaSessione(
      numeroTavolo: _tavoloSelezionato!,
      idCameriere: authProvider.user?.username ?? 'cameriere',
    );

    // CORREZIONE: Usa setTavolo per il SessionProvider
    sessionProvider.setTavolo(_tavoloSelezionato!);

    setState(() {
      _qrData = QrGeneratorService.generaDeepLink(sessione);
      _codiceSessione = sessione.codiceSessione;
    });
  }

  void _copiaCodiceSessione() {
    if (_codiceSessione != null) {
      // In un'app reale qui useremmo Clipboard.setData
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Codice sessione copiato: $_codiceSessione'),
          backgroundColor: const Color(0xFFFF6B8B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: const Color(0x99000000),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withAlpha((0.8 * 255).round()),
                      Colors.lightGreen.withAlpha((0.6 * 255).round()),
                    ],
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      'GENERATORE QR CODE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Crea QR code per i clienti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenuto
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Selezione tavolo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.7 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seleziona Tavolo:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _tavoliDisponibili.map((tavolo) {
                                final isSelected = _tavoloSelezionato == tavolo;
                                return FilterChip(
                                  label: Text(
                                    'Tavolo $tavolo',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _tavoloSelezionato = selected ? tavolo : null;
                                      _qrData = null;
                                      _codiceSessione = null;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: const Color(0xFFFF6B8B),
                                  checkmarkColor: Colors.white,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pulsante genera QR
                      if (_tavoloSelezionato != null && _qrData == null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _generaQrCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B8B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'GENERA QR CODE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // QR Code generato
                      if (_qrData != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.3 * 255).round()),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'QR Code per Tavolo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '$_tavoloSelezionato',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B8B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              QrImageView(
                                data: _qrData!,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              // Codice sessione
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Codice Sessione:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _codiceSessione ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton(
                                      onPressed: _copiaCodiceSessione,
                                      child: const Text('COPIA CODICE'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Scadenza: 3 ore',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Pulsante nuovo QR
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _tavoloSelezionato = null;
                                _qrData = null;
                                _codiceSessione = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'GENERA NUOVO QR CODE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}