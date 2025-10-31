/// FILE: empty_state.dart
/// SCOPO: Widget standardizzato per stati vuoti con messaggi informativi
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa: (nessuna dipendenza esterna)
/// - Importato da:
///   - menu_screen.dart (stato menu vuoto)
///   - varie schermate per stati vuoti
/// - Dipendenze:
///   - package:flutter/material.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione standardizzata stati vuoti
/// - Icona, titolo e sottotitolo configurabili
/// - Design coerente con tema app
/// - Riutilizzabile in tutta l'applicazione
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: MANTENUTA struttura esistente
/// - 2024-01-20: AGGIUNTA documentazione completa
/// 
/// DA VERIFICARE:
/// - Coerenza visiva con tema app
/// - Utilizzo appropriato in tutte le schermate
library;

import 'package:flutter/material.dart';

// === CLASSE: EMPTY STATE ===
// Scopo: Widget stateless per visualizzazione stati vuoti standardizzati
// Note: Design coerente per tutta l'applicazione
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icona rappresentativa
          Icon(
            icon,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          
          // Titolo
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Sottotitolo
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}