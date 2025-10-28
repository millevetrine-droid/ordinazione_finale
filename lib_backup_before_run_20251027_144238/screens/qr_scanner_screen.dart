import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'menu_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String risultato = '';

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📱 Scansiona QR Code'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    setState(() {
                      risultato = barcode.rawValue!;
                    });
                    
                    // Se abbiamo un risultato valido, vai al menu
                    if (risultato.isNotEmpty) {
                      cameraController.stop();
                      _vaiAlMenu(risultato);
                    }
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                risultato.isEmpty ? 'Inquadra il QR code del tavolo' : 'Tavolo: $risultato',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _vaiAlMenu(String numeroTavolo) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MenuScreen(numeroTavolo: numeroTavolo),
      ),
    );
  }
}