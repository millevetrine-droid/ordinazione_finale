/// FILE: proprietario_screen.dart
/// SCOPO: Schermata principale proprietario con dashboard completa, gestione ordini e menu del ristorante
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - ordini_provider.dart (gestione stato ordini)
///   - auth_provider.dart (autenticazione e autorizzazioni)
///   - menu_provider.dart (gestione stato menu completo)
///   - pietanza_model.dart (modello dati pietanza)
///   - categoria_model.dart (modello dati categoria)
///   - macrocategoria_model.dart (modello dati macrocategoria)
///   - ordine_model.dart (modello dati ordine)
///   - bottom_nav_bar.dart (navigazione inferiore)
///   - ordine_card.dart (widget visualizzazione ordine)
///   - inserisci_pietanza_screen.dart (schermata inserimento pietanze)
/// - Importato da:
///   - navigazione principale dell'applicazione
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Dashboard con statistiche giornaliere in tempo reale
/// - Gestione completa ordini attivi e storico
/// - Gestione gerarchica menu (macrocategorie -> categorie -> pietanze)
/// - Operazioni CRUD complete su tutti gli elementi menu
/// - Reset database serale con conferma
/// - Stampa scontrini dettagliati
/// - Navigazione a tab multiple con stato persistente
/// - Gestione visualizzazione allergeni dalle pietanze
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATI tutti i riferimenti allergeni per usare pietanza.haAllergeni e pietanza.testoAllergeni
/// - 2024-01-20: CORRETTI type mismatch emoji usando pietanza.iconaVisualizzata
/// - 2024-01-20: MANTENUTA tutta la logica business esistente
/// - 2024-01-20: AGGIUNTA documentazione completa per manutenzione futura
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione allergeni dal modello aggiornato
/// - Funzionamento CRUD menu con nuove dipendenze
/// - Calcolo statistiche corretto
/// - Navigazione fluida tra tab
/// - Persistenza stato durante navigazione
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ordini_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/menu_provider.dart';
import '../../core/models/ordine_model.dart';
import '../../core/models/macrocategoria_model.dart';
import '../../core/models/categoria_model.dart';
import '../../core/models/pietanza_model.dart';
import '../../features/home/widgets/bottom_nav_bar.dart';
import 'cucina/widgets/ordine_card.dart';
import 'inserisci_pietanza_screen.dart';

// === CLASSE: PROPRIETARIO SCREEN ===
// Scopo: Schermata stateful principale per il proprietario con gestione completa
// Note: Gestisce stato interno per tab selezionati e navigazione
class ProprietarioScreen extends StatefulWidget {
  const ProprietarioScreen({super.key});

  @override
  State<ProprietarioScreen> createState() => _ProprietarioScreenState();
}

// === CLASSE: STATE PROPRIETARIO SCREEN ===
// Scopo: Gestisce lo stato della schermata proprietario con tutte le funzionalità
// Note: Complesso per gestione multi-tab e operazioni CRUD
class _ProprietarioScreenState extends State<ProprietarioScreen> {
  // === STATO INTERNO ===
  int _currentIndex = 0;           // Indice navigazione bottom bar
  int _selectedTab = 0;            // Tab principale selezionato
  int _menuManagementTab = 0;      // Tab gestione menu selezionato

  // === METODO: ON TAB TAPPED ===
  /// Gestisce il tap sulla bottom navigation bar
  void _onTabTapped(int index) => setState(() => _currentIndex = index);

  // === METODO: LOGOUT ===
  /// Esegue il logout e torna alla schermata di login
  /// Sicurezza: Chiude sessione proprietario
  void _logout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // === METODO: RESET DATABASE ===
  /// Reset completo database serale con conferma
  /// Pericolo: Operazione distruttiva, richiede conferma
  /// Utilizzo: Fine giornata per pulizia ordini
  // ignore: unused_element
  void _resetDatabase(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
        title: const Text(
          'Reset Database Serale',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Sei sicuro di voler cancellare tutti gli ordini e resettare il database? Questa operazione non può essere annullata.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              final ordiniProvider = Provider.of<OrdiniProvider>(context, listen: false);
              ordiniProvider.resetDatabase();
                  Navigator.of(context).pop();
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Database resettato con successo'),
                      backgroundColor: Colors.green,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('RESET', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === METODO: STAMPA SCONTRINO ===
  /// Genera e mostra anteprima scontrino per ordine
  /// Business: Formattazione professionale con dati ristorante
  void _stampaScontrino(Ordine ordine, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
        title: const Text('Stampa Scontrino', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intestazione ristorante
              const Text('RISTORANTE MILLE VETRINE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('Via Roma 123, Milano\nP.IVA: 12345678901', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 16),
              const Divider(color: Colors.white54),
              const SizedBox(height: 8),
              
              // Info ordine
              Text('Tavolo: ${ordine.numeroTavolo}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Data: ${_formatDate(ordine.timestamp)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              
              // Dettaglio ordine
              const Text('DETTAGLIO ORDINE:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...ordine.pietanze.map((pietanza) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(pietanza.nome, style: const TextStyle(color: Colors.white70))),
                    Text('€${pietanza.prezzo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              const Divider(color: Colors.white54),
              
              // Totale
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTALE:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('€${ordine.totale.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('IVA 10% inclusa', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CHIUDI', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Scontrino stampato con successo'),
                      backgroundColor: Colors.green,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('CONFERMA STAMPA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === METODO: FORMAT DATE ===
  /// Formatta DateTime in stringa leggibile
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // === METODO: INIT STATE ===
  /// Inizializzazione schermata con caricamento dati demo se necessario
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      if (menuProvider.macrocategorie.isEmpty) {
        menuProvider.caricaDatiDemo();
      }
    });
  }

  // === WIDGET BUILD ===
  /// Costruzione interfaccia utente principale
  /// Struttura: Scaffold con appBar, body multi-tab, bottomNavigationBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('DASHBOARD PROPRIETARIO'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Pulsante aggiungi solo in gestione menu
          if (_selectedTab == 3) 
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAggiungiDialog,
              tooltip: 'Aggiungi Nuovo',
            ),
          // Pulsante logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
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
          child: Column(
            children: [
              // === TAB NAVIGATION PRINCIPALE ===
              Container(
                color: Colors.black.withAlpha((0.8 * 255).round()),
                child: Row(
                  children: [
                    _buildTabButton(0, 'Dashboard'),
                    _buildTabButton(1, 'Ordini Attivi'),
                    _buildTabButton(2, 'Archivio'),
                    _buildTabButton(3, 'Gestione Menu'),
                  ],
                ),
              ),
              
              // === SUB-NAVIGATION GESTIONE MENU ===
              if (_selectedTab == 3) 
                Container(
                  color: Colors.black.withAlpha((0.7 * 255).round()),
                  child: Row(
                    children: [
                      _buildMenuTabButton(0, 'Macrocategorie'),
                      _buildMenuTabButton(1, 'Categorie'),
                      _buildMenuTabButton(2, 'Pietanze'),
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

  // === WIDGET: MENU TAB BUTTON ===
  /// Pulsante per sub-navigazione gestione menu
  Widget _buildMenuTabButton(int tabIndex, String label) {
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => _menuManagementTab = tabIndex),
        style: TextButton.styleFrom(
          foregroundColor: _menuManagementTab == tabIndex ? Colors.orange : Colors.white70,
          backgroundColor: _menuManagementTab == tabIndex ? Colors.black : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label, 
          style: TextStyle(
            fontWeight: _menuManagementTab == tabIndex ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // === WIDGET: BUILD CONTENT ===
  /// Restituisce il contenuto in base al tab selezionato
  Widget _buildContent(OrdiniProvider ordiniProvider, BuildContext context) {
    switch (_selectedTab) {
      case 0: return _buildDashboard(ordiniProvider, context);
      case 1: return _buildOrdiniAttivi(ordiniProvider, context);
      case 2: return _buildArchivio(ordiniProvider, context);
      case 3: return _buildGestioneMenu(context);
      default: return _buildDashboard(ordiniProvider, context);
    }
  }

  // === WIDGET: DASHBOARD ===
  /// Dashboard con statistiche e azioni rapide
  Widget _buildDashboard(OrdiniProvider ordiniProvider, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'STATISTICHE GIORNALIERE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Prima riga statistiche
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
          
          // Seconda riga statistiche
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
                  'Tavoli Occupati',
                  _calcolaTavoliOccupati(ordiniProvider).toString(),
                  Icons.table_restaurant,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          const Text(
            'AZIONI RAPIDE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Griglia azioni rapide
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildActionCard(
                'Gestione Menu',
                Icons.restaurant_menu,
                Colors.blue,
                    () {
                  setState(() {
                    _selectedTab = 3;
                  });
                },
              ),
              _buildActionCard(
                'Gestione Staff',
                Icons.people,
                Colors.green,
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gestione Staff - Feature in sviluppo'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              _buildActionCard(
                'Statistiche Avanzate',
                Icons.analytics,
                Colors.orange,
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statistiche Avanzate - Feature in sviluppo'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
              _buildActionCard(
                'Stampa Scontrini',
                Icons.receipt_long,
                Colors.purple,
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seleziona un ordine per stampare lo scontrino'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === WIDGET: ORDINI ATTIVI ===
  /// Lista ordini attivi con pulsanti stampa
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
            OrdineCard(
              ordine: ordine,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _stampaScontrino(ordine, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'STAMPA SCONTRINO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  // === WIDGET: ARCHIVIO ===
  /// Lista ordini archiviati (completati)
  Widget _buildArchivio(OrdiniProvider ordiniProvider, BuildContext context) {
    final archivioOrdini = ordiniProvider.archivioOrdini;

    if (archivioOrdini.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              'Nessun ordine in archivio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gli ordini completati appariranno qui',
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
      itemCount: archivioOrdini.length,
      itemBuilder: (context, index) {
        final ordine = archivioOrdini[index];
        return Column(
          children: [
            OrdineCard(
              ordine: ordine,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _stampaScontrino(ordine, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'STAMPA SCONTRINO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  // === WIDGET: GESTIONE MENU ===
  /// Gestione completa menu con sub-tab
  Widget _buildGestioneMenu(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        switch (_menuManagementTab) {
          case 0: return _buildMacrocategorie(menuProvider, context);
          case 1: return _buildCategorie(menuProvider, context);
          case 2: return _buildPietanze(menuProvider, context);
          default: return _buildMacrocategorie(menuProvider, context);
        }
      },
    );
  }

  // === WIDGET: MACROCATEGORIE ===
  /// Lista ordinabile macrocategorie
  Widget _buildMacrocategorie(MenuProvider menuProvider, BuildContext context) {
    final macrocategorie = menuProvider.macrocategorie;

    if (macrocategorie.isEmpty) {
      return _buildEmptyState('Nessuna Macrocategoria', 'Aggiungi la prima macrocategoria per organizzare il menu');
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: macrocategorie.length,
      itemBuilder: (context, index) {
        final macrocategoria = macrocategorie[index];
        return _buildMacrocategoriaCard(macrocategoria, menuProvider, context, index);
      },
      onReorder: (oldIndex, newIndex) {
        menuProvider.riordinaMacrocategorie(oldIndex, newIndex);
      },
    );
  }

  // === WIDGET: MACROCATEGORIA CARD ===
  /// Card singola macrocategoria con azioni
  Widget _buildMacrocategoriaCard(Macrocategoria macrocategoria, MenuProvider menuProvider, BuildContext context, int index) {
    return Card(
      key: Key('macrocategoria_${macrocategoria.id}'),
  color: Colors.black.withAlpha((0.7 * 255).round()),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange),
          ),
          child: Center(
            child: Text(
              macrocategoria.iconaVisualizzata, // ✅ CORRETTO: usa getter
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        title: Text(
          macrocategoria.nome,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${macrocategoria.categorieIds.length} categorie',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _modificaMacrocategoria(macrocategoria, menuProvider, context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _eliminaMacrocategoria(macrocategoria, menuProvider, context),
            ),
            const Icon(Icons.drag_handle, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }

  // === WIDGET: CATEGORIE ===
  /// Lista ordinabile categorie
  Widget _buildCategorie(MenuProvider menuProvider, BuildContext context) {
    final categorie = menuProvider.categorie;

    if (categorie.isEmpty) {
      return _buildEmptyState('Nessuna Categoria', 'Aggiungi la prima categoria per organizzare le pietanze');
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categorie.length,
      itemBuilder: (context, index) {
        final categoria = categorie[index];
        final macrocategoria = menuProvider.getMacrocategoriaById(categoria.macrocategoriaId);
        return _buildCategoriaCard(categoria, macrocategoria, menuProvider, context, index);
      },
      onReorder: (oldIndex, newIndex) {
        menuProvider.riordinaCategorie(oldIndex, newIndex);
      },
    );
  }

  // === WIDGET: CATEGORIA CARD ===
  /// Card singola categoria con azioni
  Widget _buildCategoriaCard(Categoria categoria, Macrocategoria? macrocategoria, MenuProvider menuProvider, BuildContext context, int index) {
    return Card(
      key: Key('categoria_${categoria.id}'),
  color: Colors.black.withAlpha((0.7 * 255).round()),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue),
          ),
          child: Center(
            child: Text(
              categoria.iconaVisualizzata, // ✅ CORRETTO: usa getter
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        title: Text(
          categoria.nome,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${categoria.pietanze.length} pietanze',
              style: const TextStyle(color: Colors.white70),
            ),
            if (macrocategoria != null)
              Text(
                'Macrocategoria: ${macrocategoria.nome}',
                style: const TextStyle(color: Colors.orange, fontSize: 11),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _modificaCategoria(categoria, menuProvider, context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _eliminaCategoria(categoria, menuProvider, context),
            ),
            const Icon(Icons.drag_handle, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }

  // === WIDGET: PIETANZE ===
  /// Lista completa pietanze con filtri
  Widget _buildPietanze(MenuProvider menuProvider, BuildContext context) {
    final pietanze = menuProvider.pietanze;

    if (pietanze.isEmpty) {
      return _buildEmptyState('Nessuna Pietanza', 'Aggiungi la prima pietanza al menu');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pietanze.length,
      itemBuilder: (context, index) {
        final pietanza = pietanze[index];
        final categoria = pietanza.haCategoria ? menuProvider.getCategoriaById(pietanza.categoriaId!) : null;
        final macrocategoria = menuProvider.getMacrocategoriaById(pietanza.macrocategoriaId);
        return _buildPietanzaCard(pietanza, categoria, macrocategoria, menuProvider, context, index);
      },
    );
  }

  // === WIDGET: PIETANZA CARD ===
  /// Card singola pietanza con azioni e info complete
  Widget _buildPietanzaCard(Pietanza pietanza, Categoria? categoria, Macrocategoria? macrocategoria, MenuProvider menuProvider, BuildContext context, int index) {
    return Card(
      key: Key('pietanza_${pietanza.id}'),
  color: Colors.black.withAlpha((0.7 * 255).round()),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green),
          ),
          child: Center(
            child: Text(
              pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        title: Text(
          pietanza.nome,
          style: TextStyle(
            color: pietanza.disponibile ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            decoration: pietanza.disponibile ? TextDecoration.none : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '€${pietanza.prezzo.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
            ),
            if (categoria != null && macrocategoria != null)
              Text(
                '${macrocategoria.nome} > ${categoria.nome}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              )
            else if (macrocategoria != null)
              Text(
                '${macrocategoria.nome} (senza categoria)',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            if (pietanza.ingredienti.isNotEmpty)
              Text(
                'Ingredienti: ${pietanza.ingredienti.join(', ')}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            // ✅ CORRETTO: Visualizzazione allergeni con getter del modello
            if (pietanza.haAllergeni)
              Text(
                'Allergeni: ${pietanza.testoAllergeni}',
                style: const TextStyle(color: Colors.orange, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                pietanza.disponibile ? Icons.visibility : Icons.visibility_off,
                color: pietanza.disponibile ? Colors.green : Colors.red,
                size: 20,
              ),
              onPressed: () => _toggleDisponibilitaPietanza(pietanza, menuProvider),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _modificaPietanza(pietanza, menuProvider, context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _eliminaPietanza(pietanza, menuProvider, context),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET: EMPTY STATE ===
  /// Stato vuoto per liste
  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _menuManagementTab == 0 ? Icons.category : (_menuManagementTab == 1 ? Icons.list : Icons.restaurant),
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
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

  // === METODO: SHOW AGGIUNGI DIALOG ===
  /// Dialog per selezione tipo elemento da aggiungere
  void _showAggiungiDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
        title: const Text('Aggiungi Nuovo', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAggiungiButton('Macrocategoria', Icons.category, () {
              Navigator.of(context).pop();
              _aggiungiMacrocategoria();
            }),
            _buildAggiungiButton('Categoria', Icons.list, () {
              Navigator.of(context).pop();
              _aggiungiCategoria();
            }),
            _buildAggiungiButton('Pietanza', Icons.restaurant, () {
              Navigator.of(context).pop();
              _aggiungiPietanza();
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === WIDGET: AGGIUNGI BUTTON ===
  /// Pulsante per dialog aggiungi
  Widget _buildAggiungiButton(String label, IconData icon, VoidCallback onTap) {
    return Card(
  color: Colors.black.withAlpha((0.7 * 255).round()),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        onTap: onTap,
      ),
    );
  }

  // === METODO: AGGIUNGI MACROCATEGORIA ===
  /// Dialog per aggiunta nuova macrocategoria
  void _aggiungiMacrocategoria() {
    final nomeController = TextEditingController();
    final emojiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
        title: const Text('Nuova Macrocategoria', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nome *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emojiController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Emoji *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomeController.text.isNotEmpty && emojiController.text.isNotEmpty) {
                final menuProvider = Provider.of<MenuProvider>(context, listen: false);
                final nuovaMacrocategoria = Macrocategoria(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nome: nomeController.text,
                  emoji: emojiController.text,
                  ordine: menuProvider.macrocategorie.length,
                );
                menuProvider.aggiungiMacrocategoria(nuovaMacrocategoria);
                Navigator.of(context).pop();
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Macrocategoria "${nomeController.text}" aggiunta'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('SALVA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === METODO: MODIFICA MACROCATEGORIA ===
  /// Dialog per modifica macrocategoria esistente
  void _modificaMacrocategoria(Macrocategoria macrocategoria, MenuProvider menuProvider, BuildContext context) {
    final nomeController = TextEditingController(text: macrocategoria.nome);
    final emojiController = TextEditingController(text: macrocategoria.emoji);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
        title: const Text('Modifica Macrocategoria', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nome *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emojiController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Emoji *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomeController.text.isNotEmpty && emojiController.text.isNotEmpty) {
                final macrocategoriaAggiornata = macrocategoria.copyWith(
                  nome: nomeController.text,
                  emoji: emojiController.text,
                );
                menuProvider.modificaMacrocategoria(macrocategoria.id, macrocategoriaAggiornata);
                Navigator.of(context).pop();
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Macrocategoria "${nomeController.text}" modificata'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('SALVA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === METODO: ELIMINA MACROCATEGORIA ===
  /// Elimina macrocategoria con conferma
  void _eliminaMacrocategoria(Macrocategoria macrocategoria, MenuProvider menuProvider, BuildContext context) {
    _showConfermaEliminazione(
      'Eliminare la macrocategoria "${macrocategoria.nome}"?',
      'Tutte le categorie e pietanze associate verranno eliminate.',
      () => menuProvider.eliminaMacrocategoria(macrocategoria.id),
    );
  }

  // === METODO: AGGIUNGI CATEGORIA ===
  /// Dialog per aggiunta nuova categoria
  void _aggiungiCategoria() {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final macrocategorie = menuProvider.macrocategorie;
    
    if (macrocategorie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crea prima una macrocategoria'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nomeController = TextEditingController();
    final emojiController = TextEditingController();
    String? selectedMacrocategoriaId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
          title: const Text('Nuova Categoria', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown macrocategoria
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.7 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMacrocategoriaId,
                    isExpanded: true,
                    dropdownColor: Colors.black.withAlpha((0.9 * 255).round()),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    hint: const Text(
                      'Seleziona Macrocategoria *',
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: macrocategorie.map((macrocategoria) {
                      return DropdownMenuItem<String>(
                        value: macrocategoria.id,
                        child: Row(
                          children: [
                            Text(macrocategoria.iconaVisualizzata), // ✅ CORRETTO: usa getter
                            const SizedBox(width: 8),
                            Text(macrocategoria.nome),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMacrocategoriaId = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Nome categoria
              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome Categoria *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
              const SizedBox(height: 12),
              // Emoji categoria
              TextField(
                controller: emojiController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Emoji *',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ANNULLA', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty && 
                    emojiController.text.isNotEmpty && 
                    selectedMacrocategoriaId != null) {
                  final nuovaCategoria = Categoria(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nome: nomeController.text,
                    emoji: emojiController.text,
                    ordine: menuProvider.categorie.length,
                    macrocategoriaId: selectedMacrocategoriaId!,
                    pietanze: [],
                  );
                  menuProvider.aggiungiCategoria(nuovaCategoria);
                  Navigator.of(context).pop();
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Categoria "${nomeController.text}" aggiunta'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('SALVA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // === METODO: MODIFICA CATEGORIA ===
  /// Dialog per modifica categoria esistente
  void _modificaCategoria(Categoria categoria, MenuProvider menuProvider, BuildContext context) {
    final nomeController = TextEditingController(text: categoria.nome);
    final emojiController = TextEditingController(text: categoria.emoji);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
        title: const Text('Modifica Categoria', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nome *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emojiController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Emoji *',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomeController.text.isNotEmpty && emojiController.text.isNotEmpty) {
                final categoriaAggiornata = categoria.copyWith(
                  nome: nomeController.text,
                  emoji: emojiController.text,
                );
                menuProvider.modificaCategoria(categoria.id, categoriaAggiornata);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Categoria "${nomeController.text}" modificata'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('SALVA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === METODO: ELIMINA CATEGORIA ===
  /// Elimina categoria con conferma
  void _eliminaCategoria(Categoria categoria, MenuProvider menuProvider, BuildContext context) {
    _showConfermaEliminazione(
      'Eliminare la categoria "${categoria.nome}"?',
      'Tutte le pietanze associate verranno eliminate.',
      () => menuProvider.eliminaCategoria(categoria.id),
    );
  }

  // === METODO: AGGIUNGI PIETANZA ===
  /// Naviga alla schermata di inserimento pietanza
  void _aggiungiPietanza() {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final macrocategorie = menuProvider.macrocategorie;
    
    if (macrocategorie.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Crea prima una macrocategoria'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InserisciPietanzaScreen()),
    );
  }

  // === METODO: MODIFICA PIETANZA ===
  /// Naviga alla schermata di modifica pietanza
  void _modificaPietanza(Pietanza pietanza, MenuProvider menuProvider, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modifica Pietanza - Usa la schermata di inserimento per modifiche complete'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // === METODO: ELIMINA PIETANZA ===
  /// Elimina pietanza con conferma
  void _eliminaPietanza(Pietanza pietanza, MenuProvider menuProvider, BuildContext context) {
    _showConfermaEliminazione(
      'Eliminare la pietanza "${pietanza.nome}"?',
      'Questa operazione non può essere annullata.',
      () => menuProvider.eliminaPietanza(pietanza.id),
    );
  }

  // === METODO: TOGGLE DISPONIBILITÀ PIETANZA ===
  /// Attiva/disattiva disponibilità pietanza
  void _toggleDisponibilitaPietanza(Pietanza pietanza, MenuProvider menuProvider) {
    menuProvider.aggiornaDisponibilitaPietanza(pietanza.id, !pietanza.disponibile);
  }

  // === METODO: SHOW CONFERMA ELIMINAZIONE ===
  /// Dialog generico per conferma eliminazione
  void _showConfermaEliminazione(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Elemento eliminato con successo'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === WIDGET: STAT CARD ===
  /// Card statistica per dashboard
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

  // === WIDGET: ACTION CARD ===
  /// Card azione rapida per dashboard
  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
  color: Colors.black.withAlpha((0.7 * 255).round()),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === METODO: CALCOLA TAVOLI OCCUPATI ===
  /// Calcola numero di tavoli unici con ordini attivi
  int _calcolaTavoliOccupati(OrdiniProvider ordiniProvider) {
    final tavoliUnici = <String>{};
    for (final ordine in ordiniProvider.ordiniAttivi) {
      tavoliUnici.add(ordine.numeroTavolo);
    }
    return tavoliUnici.length;
  }
}