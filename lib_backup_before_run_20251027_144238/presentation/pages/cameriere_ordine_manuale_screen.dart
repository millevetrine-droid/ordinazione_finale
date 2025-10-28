/// FILE: cameriere_ordine_manuale_screen.dart
/// SCOPO: Schermata per inserimento ordini manuali da parte del cameriere con carrello temporaneo
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - menu_provider.dart (gestione stato menu e categorie)
///   - cart_provider.dart (gestione carrello temporaneo)
///   - ordini_provider.dart (gestione invio ordini)
///   - auth_provider.dart (autenticazione cameriere)
///   - pietanza_model.dart (modello dati pietanza)
///   - ordine_model.dart (modello dati ordine)
/// - Importato da:
///   - navigazione cameriere
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Selezione tavolo e inserimento note ordine
/// - Carrello temporaneo per composizione ordine
/// - Navigazione categorie e selezione pietanze
/// - Gestione aggiunta/rimozione elementi carrello
/// - Invio ordine completo alla cucina
/// - Gestione visualizzazione allergeni dalle pietanze
/// - Validazione campi obbligatori
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATI tutti i riferimenti allergeni per usare pietanza.haAllergeni e pietanza.testoAllergeni
/// - 2024-01-20: CORRETTI type mismatch emoji usando pietanza.iconaVisualizzata
/// - 2024-01-20: MANTENUTA logica carrello e invio ordine esistente
/// - 2024-01-20: AGGIUNTA documentazione completa per manutenzione futura
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione allergeni dal modello aggiornato
/// - Funzionamento carrello temporaneo
/// - Invio ordine corretto al provider
/// - Validazione campi obbligatori
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/menu_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/ordini_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/pietanza_model.dart';
import '../../core/models/ordine_model.dart';

// === CLASSE: CAMERIERE ORDINE MANUALE SCREEN ===
// Scopo: Schermata stateful per inserimento ordini manuali cameriere
// Note: Gestisce stato interno per selezione categorie e carrello
class CameriereOrdineManualeScreen extends StatefulWidget {
  const CameriereOrdineManualeScreen({super.key});

  @override
  State<CameriereOrdineManualeScreen> createState() => _CameriereOrdineManualeScreenState();
}

// === CLASSE: STATE CAMERIERE ORDINE MANUALE ===
// Scopo: Gestisce lo stato della schermata ordine manuale
// Note: Complesso per gestione form, carrello e navigazione categorie
class _CameriereOrdineManualeScreenState extends State<CameriereOrdineManualeScreen> {
  // === CONTROLLER INPUT ===
  final TextEditingController _tavoloController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  // === STATO SELEZIONI ===
  String _categoriaSelezionata = '';

  // === METODO: INIT STATE ===
  /// Inizializzazione con valori default
  @override
  void initState() {
    super.initState();
    _tavoloController.text = '1'; // Valore di default
  }

  // === METODO: AGGIUNGI AL CARRELLO ===
  /// Aggiunge una pietanza al carrello temporaneo
  /// Feedback: SnackBar di conferma
  void _aggiungiAlCarrello(Pietanza pietanza) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.aggiungiAlCarrello(pietanza);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pietanza.nome} aggiunto al carrello'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // === METODO: INVIA ORDINE ===
  /// Invia l'ordine completo alla cucina dopo validazione
  /// Sicurezza: Controlla campi obbligatori e carrello non vuoto
  void _inviaOrdine() {
    if (_tavoloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci il numero del tavolo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ordiniProvider = Provider.of<OrdiniProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Il carrello è vuoto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Creazione nuovo ordine
    final nuovoOrdine = Ordine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      numeroTavolo: _tavoloController.text.trim(),
      pietanze: cartProvider.items.map((item) => item.pietanza).toList(),
      stato: StatoOrdine.inAttesa,
      timestamp: DateTime.now(),
      idCameriere: authProvider.user?.username ?? 'cameriere',
      note: _noteController.text.trim(),
    );

    // Invio ordine e pulizia
    ordiniProvider.aggiungiOrdine(nuovoOrdine);
    cartProvider.svuotaCarrello();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ordine per Tavolo ${_tavoloController.text} inviato alla cucina!'),
        backgroundColor: Colors.green,
      ),
    );

    // Reset form
    _noteController.clear();
    setState(() => _categoriaSelezionata = '');
  }

  // === METODO: SVUOTA CARRELLO ===
  /// Svuota il carrello temporaneo
  void _svuotaCarrello() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.svuotaCarrello();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Carrello svuotato'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // === METODO: DISPOSE ===
  /// Pulizia risorse controller
  @override
  void dispose() {
    _tavoloController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // === WIDGET BUILD ===
  /// Costruzione interfaccia utente principale
  /// Struttura: Header info + selezione categorie + lista pietanze + azioni
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final categorie = menuProvider.categorie;
    
    // Inizializza categoria selezionata se vuota
    if (categorie.isNotEmpty && _categoriaSelezionata.isEmpty) {
      _categoriaSelezionata = categorie.first.id;
    }

    final categoria = menuProvider.getCategoriaById(_categoriaSelezionata);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('ORDINE MANUALE'),
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
          color: Colors.black.withAlpha((0.7 * 255).round()),
          child: Column(
            children: [
              // === HEADER: INFO TAVOLO E CARRELLO ===
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withAlpha((0.8 * 255).round()),
                child: Column(
                  children: [
                    // Riga tavolo e carrello
                    Row(
                      children: [
                        // Input numero tavolo
                        Expanded(
                          child: TextFormField(
                            controller: _tavoloController,
                            decoration: const InputDecoration(
                              labelText: 'Numero Tavolo',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Info carrello
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withAlpha((0.2 * 255).round()),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.yellow),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Carrello',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${cartProvider.totaleElementi} elementi',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '€${cartProvider.totale.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Input note ordine
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note ordine (opzionale)',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              // === SELEZIONE CATEGORIA ===
              Container(
                color: Colors.black.withAlpha((0.8 * 255).round()),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: categorie.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat.nome),
                        selected: _categoriaSelezionata == cat.id,
                        onSelected: (selected) {
                          setState(() => _categoriaSelezionata = cat.id);
                        },
                        backgroundColor: Colors.black.withAlpha((0.5 * 255).round()),
                        selectedColor: const Color(0xFFFF6B8B),
                        labelStyle: TextStyle(
                          color: _categoriaSelezionata == cat.id ? Colors.white : Colors.white70,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),

              // === LISTA PIETANZE CATEGORIA SELEZIONATA ===
              Expanded(
                child: categoria != null
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: categoria.pietanze.length,
                        itemBuilder: (context, index) {
                          final pietanza = categoria.pietanze[index];
                          return Card(
                            color: Colors.black.withAlpha((0.8 * 255).round()),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Emoji pietanza - ✅ CORRETTO: usa iconaVisualizzata
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha((0.1 * 255).round()),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Center(
                                      child: Text(
                                        pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Dettagli pietanza
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Nome pietanza
                                        Text(
                                          pietanza.nome,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        
                                        // Descrizione
                                        Text(
                                          pietanza.descrizione,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        
                                        // Prezzo
                                        Text(
                                          '€${pietanza.prezzo.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Pulsante aggiungi
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add_circle, color: Colors.green),
                                        onPressed: () => _aggiungiAlCarrello(pietanza),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Aggiungi',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'Seleziona una categoria',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),

              // === AZIONI: SVUOTA E INVIA ===
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withAlpha((0.9 * 255).round()),
                child: Row(
                  children: [
                    // Pulsante svuota carrello
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _svuotaCarrello,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'SVUOTA CARRELLO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Pulsante invia ordine
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _inviaOrdine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'INVIA ORDINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}