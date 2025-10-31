// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ordinazione/core/services/session_service.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/session_provider.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isProcessing = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withAlpha((0.6 * 255).round()),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.8 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: Color(0xFF4ECDC4),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Scanner QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 400,
                        width: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: MobileScanner(
                            onDetect: (capture) async {
                              if (_isProcessing) return;
                              final List<Barcode> barcodes = capture.barcodes;
                              if (barcodes.isEmpty) return;
                              final raw = barcodes.first.rawValue;
                              if (raw == null || raw.isEmpty) return;
                              setState(() { _isProcessing = true; });
                              try {
                                final code = raw.trim();
                                final s = await SessionService().joinSessionByCode(code);
                                if (s != null) {
                                  if (!mounted) return;
                                  // Update local provider and start remote listen
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
                                if (mounted) setState(() { _isProcessing = false; });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}