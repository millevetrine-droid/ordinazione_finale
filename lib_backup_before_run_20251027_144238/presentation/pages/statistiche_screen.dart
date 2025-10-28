/// FILE: statistiche_screen.dart
/// SCOPO: Schermata visualizzazione statistiche avanzate del ristorante con dati analitici
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - ordini_provider.dart (dati statistiche ordini)
///   - menu_provider.dart (dati statistiche menu)
/// - Importato da:
///   - navigazione principale app
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Dashboard statistiche giornaliere con KPI
/// - Visualizzazione pietanze più vendute (feature in sviluppo)
/// - Analisi categorie menu con conteggio pietanze
/// - Esportazione dati in CSV (feature in sviluppo)
/// - Grafici e visualizzazioni dati (feature in sviluppo)
/// - Layout responsive per dati complessi
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: MANTENUTA struttura base per future implementazioni
/// - 2024-01-20: AGGIUNTA documentazione completa per manutenzione futura
/// - 2024-01-20: CORRETTI riferimenti a modelli per consistenza
/// 
/// DA VERIFICARE:
/// - Calcolo corretto statistiche dai provider
/// - Preparazione struttura per future feature
/// - Layout su diversi dispositivi
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ordini_provider.dart';
import '../../core/providers/menu_provider.dart';

// === CLASSE: STATISTICHE SCREEN ===
// Scopo: Schermata stateless per visualizzazione statistiche
// Note: Base per future implementazioni di analisi avanzate
class StatisticheScreen extends StatelessWidget {
  const StatisticheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('STATISTICHE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Pulsante esportazione (feature in sviluppo)
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Esportazione statistiche in CSV - Feature in sviluppo'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Esporta CSV',
          ),
        ],
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
          child: Consumer2<OrdiniProvider, MenuProvider>(
            builder: (context, ordiniProvider, menuProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === STATISTICHE GIORNALIERE ===
                    const Text(
                      'STATISTICHE GIORNALIERE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // === CARDS STATISTICHE PRINCIPALI ===
                    // Prima riga
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Ordini Oggi',
                            ordiniProvider.totaleOrdiniOggi.toString(),
                            Icons.receipt,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Incasso Oggi',
                            '€${ordiniProvider.incassoOggi.toStringAsFixed(2)}',
                            Icons.euro,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Seconda riga
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Ordini Attivi',
                            ordiniProvider.ordiniAttivi.length.toString(),
                            Icons.timer,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pietanze Totali',
                            menuProvider.pietanze.length.toString(),
                            Icons.restaurant,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // === PIETANZE PIÙ VENDUTE (FEATURE IN SVILUPPO) ===
                    const Text(
                      'PIETANZE PIÙ VENDUTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPietanzePiuVendute(),

                    const SizedBox(height: 30),

                    // === CATEGORIE MENU ===
                    const Text(
                      'CATEGORIE MENU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategorieStats(menuProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // === WIDGET: STAT CARD ===
  /// Card singola statistica con icona e valore
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET: PIETANZE PIÙ VENDUTE ===
  /// Sezione pietanze più vendute (feature in sviluppo)
  Widget _buildPietanzePiuVendute() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Analisi vendite pietanze', style: TextStyle(color: Colors.white70)),
              Text('Feature in sviluppo', style: TextStyle(color: Colors.orange)),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ],
      ),
    );
  }

  // === WIDGET: CATEGORIE STATS ===
  /// Statistiche categorie menu con conteggio pietanze
  Widget _buildCategorieStats(MenuProvider menuProvider) {
    final categorie = menuProvider.categorie;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final categoria in categorie.take(5)) // Mostra prime 5 categorie
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Info categoria
                  Row(
                    children: [
                      Text(
                        categoria.iconaVisualizzata, // ✅ CORRETTO: usa getter
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        categoria.nome,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  // Conteggio pietanze
                  Text(
                    '${categoria.numeroPietanze} pietanze',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          
          // Messaggio categorie aggiuntive
          if (categorie.length > 5)
            Text(
              '+ ${categorie.length - 5} altre categorie...',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
        ],
      ),
    );
  }
}