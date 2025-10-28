import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../models/ordine_model.dart';
import '../services/firebase_service.dart';
import 'proprietario_dashboard.dart';
import 'pulisci_database_screen.dart';

class ProprietarioScreen extends StatefulWidget {
  const ProprietarioScreen({super.key});

  @override
  State<ProprietarioScreen> createState() => _ProprietarioScreenState();
}

class _ProprietarioScreenState extends State<ProprietarioScreen> {
  List<Ordine> _ordini = [];
  bool _isLoading = true;
  bool _errorCaricamento = false;

  @override
  void initState() {
    super.initState();
    _caricaOrdiniUnaVolta();
  }

  // 👇 CORRETTO: Metodo che ritorna Future<void>
  Future<void> _caricaOrdiniUnaVolta() async {
    try {
      setState(() {
        _isLoading = true;
        _errorCaricamento = false;
      });

      final ordini = await FirebaseService.orders.getTuttiOrdiniUnaVolta()
          .timeout(const Duration(seconds: 5), onTimeout: () {
          dev.log('⚠️ Timeout caricamento ordini - uso dati locali', name: 'ProprietarioScreen');
          return []; // 👈 Fallback a lista vuota
        });

      setState(() {
        _ordini = ordini;
        _isLoading = false;
      });

  dev.log('✅ Ordini caricati: ${_ordini.length} ordini', name: 'ProprietarioScreen');

    } catch (e) {
      dev.log('❌ Errore caricamento ordini: $e', name: 'ProprietarioScreen');
      setState(() {
        _isLoading = false;
        _errorCaricamento = true;
        _ordini = []; // 👈 Mostra comunque la dashboard
      });
    }
  }

  // 👇 CORRETTO: Ricarica manuale con pull-to-refresh
  Future<void> _ricaricaOrdini() async {
    setState(() {
      _isLoading = true;
      _errorCaricamento = false;
    });
    await _caricaOrdiniUnaVolta();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👑 PROPRIETARIO - Dashboard'),
        backgroundColor: Colors.deepOrange[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 👇 NUOVO: Pulsante ricarica manuale
          if (_errorCaricamento || !_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _ricaricaOrdini,
              tooltip: 'Ricarica ordini',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'statistiche',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('📈 Statistiche Complete'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pulisci',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('🧹 Pulizia Database'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorCaricamento) {
      return _buildErroreCaricamento();
    }

    // 👇 OTTIMIZZATO: RefreshIndicator per ricarica manuale
    return RefreshIndicator(
      onRefresh: _ricaricaOrdini,
      child: ProprietarioDashboard(ordini: _ordini),
    );
  }

  // 👇 NUOVO: Gestione errori di caricamento
  Widget _buildErroreCaricamento() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.deepOrange),
            const SizedBox(height: 16),
            const Text(
              'Errore di connessione',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Impossibile caricare gli ordini.\nControlla la connessione e riprova.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('RIPROVA'),
              onPressed: _ricaricaOrdini,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'statistiche':
        _mostraStatistiche(context);
        break;
      case 'pulisci':
        Navigator.push(context, 
            MaterialPageRoute(builder: (_) => const PulisciDatabaseScreen()));
        break;
    }
  }

  void _mostraStatistiche(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('📈 Statistiche Complete', style: TextStyle(color: Colors.black87)),
        content: const Text('Funzionalità in sviluppo\n\nProssimamente: statistiche dettagliate per pietanza, orari di punta, incassi giornalieri.',
            style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.deepOrange)),
          ),
        ],
      ),
    );
  }
}