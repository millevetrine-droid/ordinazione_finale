/// FILE: bottom_nav_bar.dart
/// SCOPO: Widget navigazione inferiore standardizzata per tutta l'applicazione con i link corretti
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa: (nessuna dipendenza esterna)
/// - Importato da:
///   - tutte le schermate principali dell'app
/// - Dipendenze:
///   - package:flutter/material.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Navigazione inferiore con 5 sezioni corrette: Home, Offerte, Ordina, Miei Punti, Altro
/// - Icone appropriate per ogni sezione
/// - Design coerente con tema app
/// - Gestione callback per cambio tab
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: CORRETTI tutti i link e le icone con la versione giusta
/// - 2024-01-20: RIPRISTINATA la struttura originale corretta
/// 
/// DA VERIFICARE:
/// - Corrispondenza con la navigazione reale dell'app
/// - Funzionamento callback onTabTapped
library;

import 'package:flutter/material.dart';

// === CLASSE: BOTTOM NAV BAR ===
// Scopo: Widget stateless per navigazione inferiore con link corretti
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
    color: Colors.black.withAlpha(230),
        border: const Border(
          top: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFFFF6B8B),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        // ✅ CORRETTO: I 5 tab con link e icone giuste
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Offerte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Ordina',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Miei Punti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Altro',
          ),
        ],
      ),
    );
  }
}