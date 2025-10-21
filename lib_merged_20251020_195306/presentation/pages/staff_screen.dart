/// FILE: staff_screen.dart
/// SCOPO: Schermata principale per lo staff del ristorante con gestione multi-area (ordini, cucina, sala)
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - auth_provider.dart (autenticazione e controllo permessi)
///   - ordini_provider.dart (gestione stato ordini)
///   - pietanza_model.dart (modello dati pietanza)
///   - ordine_model.dart (modello dati ordine)
///   - bottom_nav_bar.dart (navigazione inferiore)
///   - ordine_card.dart (widget visualizzazione ordine)
/// - Importato da:
///   - navigazione principale dell'applicazione
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione ordini attivi per tutti gli staff
/// - Area cucina con gestione preparazione pietanze (solo per autorizzati)
/// - Area sala con gestione servizio pietanze pronte (solo per autorizzati)
/// - Controllo permessi basato su ruolo utente
/// - Navigazione a tab con contenuto contestuale
/// - Gestione visualizzazione allergeni dalle pietanze
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATI tutti i riferimenti allergeni per usare pietanza.haAllergeni e pietanza.testoAllergeni
/// - 2024-01-20: CORRETTI type mismatch emoji usando pietanza.iconaVisualizzata
/// - 2024-01-20: MANTENUTA logica controllo permessi esistente
/// - 2024-01-20: AGGIUNTA documentazione completa per manutenzione futura
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione allergeni dal modello aggiornato
/// - Controlli permessi funzionanti per cucina/sala
/// - Navigazione fluida tra tab
/// - Sync dati in tempo reale tra aree
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/ordini_provider.dart';
import '../../core/models/ordine_model.dart';
import '../../core/models/pietanza_model.dart'; // ✅ AGGIUNTO per referenza diretta
import '../../features/home/widgets/bottom_nav_bar.dart';
import 'cucina/widgets/ordine_card.dart';

// === CLASSE: STAFF SCREEN ===
// Scopo: Schermata stateful principale per lo staff con gestione multi-area
// Note: Gestisce stato interno per tab selezionati e controlli permessi
class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

// === CLASSE: STATE STAFF SCREEN ===
// Scopo: Gestisce lo stato della schermata staff con controlli permessi
// Note: Complesso per gestione multi-area con autorizzazioni differenziate
class _StaffScreenState extends State<StaffScreen> {
  // === STATO INTERNO ===
  int _currentIndex = 0;     // Indice navigazione bottom bar
  int _selectedTab = 0;      // Tab principale selezionato

  // === METODO: ON TAB TAPPED ===
  /// Gestisce il tap sulla bottom navigation bar
  void _onTabTapped(int index) => setState(() => _currentIndex = index);

  // === WIDGET BUILD ===
  /// Costruzione interfaccia utente principale
  /// Struttura: Scaffold con appBar, body multi-tab, bottomNavigationBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('AREA STAFF'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: Column(
            children: [
              // === TAB NAVIGATION PRINCIPALE ===
              Container(
                color: Colors.black.withAlpha((0.8 * 255).round()),
                child: Row(
                  children: [
                    _buildTabButton(0, 'Ordini Attivi'),
                    _buildTabButton(1, 'Cucina'),
                    _buildTabButton(2, 'Sala'),
                  ],
                ),
              ),
              
              // === CONTENUTO PRINCIPALE ===
              Expanded(
                child: Consumer<OrdiniProvider>(
                  builder: (context, ordiniProvider, child) => _buildContent(ordiniProvider, context),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  // === WIDGET: TAB BUTTON ===
  /// Pulsante per tab navigazione principale
  Widget _buildTabButton(int tabIndex, String label) {
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => _selectedTab = tabIndex),
        style: TextButton.styleFrom(
          foregroundColor: _selectedTab == tabIndex ? const Color(0xFFFF6B8B) : Colors.white70,
          backgroundColor: _selectedTab == tabIndex ? Colors.black : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(label, style: TextStyle(fontWeight: _selectedTab == tabIndex ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  // === WIDGET: BUILD CONTENT ===
  /// Restituisce il contenuto in base al tab selezionato con controlli permessi
  Widget _buildContent(OrdiniProvider ordiniProvider, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (_selectedTab) {
      case 0: return _buildOrdiniAttivi(ordiniProvider, context);
      case 1: 
        if (authProvider.canGestireCucina) {
          return _buildCucina(ordiniProvider, context);
        } else {
          return _buildAccessoNegato('Cucina');
        }
      case 2: 
        if (authProvider.canGestireSala) {
          return _buildSala(ordiniProvider, context);
        } else {
          return _buildAccessoNegato('Sala');
        }
      default: return _buildOrdiniAttivi(ordiniProvider, context);
    }
  }

  // === WIDGET: ORDINI ATTIVI ===
  /// Lista ordini attivi visibile a tutto lo staff
  Widget _buildOrdiniAttivi(OrdiniProvider ordiniProvider, BuildContext context) {
    final ordiniAttivi = ordiniProvider.ordiniAttivi;

    if (ordiniAttivi.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              'Nessun ordine attivo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tutti gli ordini sono completati',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ordiniAttivi.length,
      itemBuilder: (context, index) {
        final ordine = ordiniAttivi[index];
        return Column(
          children: [
            OrdineCard(ordine: ordine),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  // === WIDGET: CUCINA ===
  /// Area cucina per gestione preparazione pietanze (solo staff autorizzato)
  Widget _buildCucina(OrdiniProvider ordiniProvider, BuildContext context) {
    final ordiniCucina = ordiniProvider.getOrdiniCucinaForCameriere();

    if (ordiniCucina.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              'Nessun ordine in cucina',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tutti gli ordini sono pronti o completati',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ordiniCucina.length,
      itemBuilder: (context, index) {
        final ordine = ordiniCucina[index];
        return Column(
          children: [
            OrdineCard(ordine: ordine),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  // === WIDGET: SALA ===
  /// Area sala per gestione servizio pietanze pronte (solo staff autorizzato)
  Widget _buildSala(OrdiniProvider ordiniProvider, BuildContext context) {
    final pietanzePronte = ordiniProvider.getPietanzePronteDaServire();

    if (pietanzePronte.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.room_service, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              'Nessuna pietanza pronta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tutte le pietanze sono state servite',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pietanzePronte.length,
      itemBuilder: (context, index) {
        final item = pietanzePronte[index];
        final ordine = item['ordine'] as Ordine;
        final pietanza = item['pietanza'] as Pietanza;
        final tavolo = item['tavolo'] as String;

        return Card(
          color: Colors.black.withAlpha((0.7 * 255).round()),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            title: Text(
              pietanza.nome,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tavolo: $tavolo',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Ordine: ${ordine.id.substring(0, 8)}...',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                // ✅ CORRETTO: Visualizzazione allergeni con getter del modello
                if (pietanza.haAllergeni)
                  Text(
                    '⚠️ Allergeni: ${pietanza.testoAllergeni}', // ✅ CORRETTO: usa getter del modello
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                ordiniProvider.segnaPietanzaServita(
                  ordineId: ordine.id,
                  pietanzaId: pietanza.id,
                  user: 'Staff',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${pietanza.nome} segnata come servita'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                'SERVIRE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // === WIDGET: ACCESSO NEGATO ===
  /// Messaggio di accesso negato per aree non autorizzate
  Widget _buildAccessoNegato(String area) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Accesso negato',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Non hai i permessi per accedere all\'area $area',
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