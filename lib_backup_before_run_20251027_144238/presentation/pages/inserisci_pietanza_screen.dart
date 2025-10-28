/// FILE: inserisci_pietanza_screen.dart
/// SCOPO: Schermata per l'inserimento di nuove pietanze nel menu con form completo e gestione allergeni
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - pietanza_model.dart (modello dati pietanza)
///   - menu_provider.dart (gestione stato menu)
///   - macrocategoria_model.dart (gerarchia menu)
///   - categoria_model.dart (gerarchia menu)
/// - Importato da:
///   - proprietario_screen.dart (navigazione da gestione menu)
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
///   - package:image_picker/image_picker.dart (selezione foto)
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Form completo per inserimento nuove pietanze
/// - Selezione gerarchica macrocategoria -> categoria
/// - Gestione emoji e immagini per rappresentazione visiva
/// - Gestione lista ingredienti dinamica
/// - ✅ NUOVA: Gestione lista allergeni dinamica
/// - Validazione campi obbligatori
/// - Preview anteprima pietanza
/// - Integrazione con MenuProvider per persistenza
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIUNTA sezione allergeni completa con UI
/// - 2024-01-20: AGGIORNATO salvataggio per includere allergeni
/// - 2024-01-20: MANTENUTA compatibilità con struttura esistente
/// 
/// DA VERIFICARE:
/// - Corretto salvataggio lista allergeni nel modello
/// - Validazione consistente tra emoji e immagini
/// - Corretta navigazione dopo salvataggio
/// - Gestione errori selezione immagini
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/menu_provider.dart';
import '../../core/models/macrocategoria_model.dart';
import '../../core/models/categoria_model.dart';
import '../../core/models/pietanza_model.dart';

// === CLASSE: INSERISCI PIETANZA SCREEN ===
// Scopo: Schermata stateful per la creazione di nuove pietanze
// Note: Gestisce stato interno per form complesso con multiple sezioni
class InserisciPietanzaScreen extends StatefulWidget {
  const InserisciPietanzaScreen({super.key});

  @override
  State<InserisciPietanzaScreen> createState() => _InserisciPietanzaScreenState();
}

// === CLASSE: STATE INSERISCI PIETANZA ===
// Scopo: Gestisce lo stato della schermata di inserimento pietanza
// Note: Contiene tutta la logica di gestione form, selezione e salvataggio
class _InserisciPietanzaScreenState extends State<InserisciPietanzaScreen> {
  // === CONTROLLER FORM ===
  final _formKey = GlobalKey<FormState>();  // Key per validazione form
  final ImagePicker _imagePicker = ImagePicker(); // Picker per selezione immagini
  
  // === CONTROLLER INPUT TEXT ===
  final _nomeController = TextEditingController();        // Nome pietanza
  final _descrizioneController = TextEditingController(); // Descrizione
  final _prezzoController = TextEditingController();      // Prezzo
  final _emojiController = TextEditingController();       // Emoji
  final _ingredientiController = TextEditingController(); // Input ingredienti
  final _allergeniController = TextEditingController();   // ✅ NUOVO: Input allergeni
  
  // === STATO SELEZIONI ===
  String? _selectedMacrocategoriaId;  // Macrocategoria selezionata
  String? _selectedCategoriaId;       // Categoria selezionata (opzionale)
  final List<String> _ingredientiList = []; // Lista ingredienti accumulati
  final List<String> _allergeniList = [];   // ✅ NUOVO: Lista allergeni accumulati
  String? _selectedImageUrl;          // URL immagine selezionata

  // === METODO: DISPOSE ===
  /// Pulizia risorse quando il widget viene distrutto
  /// Importante: Previene memory leak dai controller
  @override
  void dispose() {
    _nomeController.dispose();
    _descrizioneController.dispose();
    _prezzoController.dispose();
    _emojiController.dispose();
    _ingredientiController.dispose();
    _allergeniController.dispose(); // ✅ NUOVO: cleanup controller allergeni
    super.dispose();
  }

  // === METODO: AGGIUNGI ALLERGENE ===
  /// ✅ NUOVO: Aggiunge un allergene alla lista dagli input
  /// Validazione: Controlla che non sia vuoto e non duplicato
  void _aggiungiAllergene() {
    final allergene = _allergeniController.text.trim();
    if (allergene.isNotEmpty && !_allergeniList.contains(allergene)) {
      setState(() {
        _allergeniList.add(allergene);
        _allergeniController.clear();
      });
    }
  }

  // === METODO: RIMUOVI ALLERGENE ===
  /// ✅ NUOVO: Rimuove un allergene dalla lista per indice
  void _rimuoviAllergene(int index) {
    setState(() {
      _allergeniList.removeAt(index);
    });
  }

  // === METODO: SCEGLI FOTO ===
  /// Apre il selettore immagini per scegliere una foto
  /// Utilizzo: Gallery con limitazioni dimensioni e qualità
  /// Gestione errori: SnackBar in caso di errore
  Future<void> _scegliFoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (!mounted) return;
        setState(() {
          _selectedImageUrl = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella selezione foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // === METODO: RIMUOVI FOTO ===
  /// Rimuove la foto selezionata dall'anteprima
  void _rimuoviFoto() {
    setState(() {
      _selectedImageUrl = null;
    });
  }

  // === METODO: AGGIUNGI INGREDIENTE ===
  /// Aggiunge un ingrediente alla lista dagli input
  /// Validazione: Controlla che non sia vuoto e non duplicato
  void _aggiungiIngrediente() {
    final ingrediente = _ingredientiController.text.trim();
    if (ingrediente.isNotEmpty && !_ingredientiList.contains(ingrediente)) {
      setState(() {
        _ingredientiList.add(ingrediente);
        _ingredientiController.clear();
      });
    }
  }

  // === METODO: RIMUOVI INGREDIENTE ===
  /// Rimuove un ingrediente dalla lista per indice
  void _rimuoviIngrediente(int index) {
    setState(() {
      _ingredientiList.removeAt(index);
    });
  }

  // === METODO: SALVA PIETANZA ===
  /// Salva la nuova pietanza dopo validazione
  /// Logica: Crea oggetto Pietanza e lo aggiunge al MenuProvider
  /// Validazione: Campi obbligatori e almeno emoji o foto
  /// Navigazione: Torna indietro dopo salvataggio
  void _salvaPietanza() {
    if (_formKey.currentState!.validate() && _selectedMacrocategoriaId != null) {
      // Validazione: almeno emoji o foto
      if (_emojiController.text.isEmpty && _selectedImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inserisci un\'emoji o una foto per la pietanza'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Creazione nuova pietanza con tutti i campi
      final nuovaPietanza = Pietanza(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text,
        descrizione: _descrizioneController.text,
        prezzo: double.parse(_prezzoController.text),
        emoji: _emojiController.text.isEmpty ? null : _emojiController.text,
        imageUrl: _selectedImageUrl,
        ingredienti: _ingredientiList,
        allergeni: _allergeniList, // ✅ CORRETTO: ora il campo esiste nel modello
        disponibile: true,
        stato: StatoPietanza.inAttesa,
        categoriaId: _selectedCategoriaId,
        macrocategoriaId: _selectedMacrocategoriaId!,
      );

      // Salvataggio tramite provider
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      menuProvider.aggiungiPietanza(nuovaPietanza);

      // Reset form dopo salvataggio
      _formKey.currentState!.reset();
      setState(() {
        _selectedMacrocategoriaId = null;
        _selectedCategoriaId = null;
        _ingredientiList.clear();
        _allergeniList.clear(); // ✅ NUOVO: reset lista allergeni
        _selectedImageUrl = null;
      });

      // Feedback utente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pietanza aggiunta con successo!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Torna alla schermata precedente
      Navigator.of(context).pop();
    } else {
      // Validazione fallita
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compila tutti i campi obbligatori'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // === WIDGET BUILD ===
  /// Costruzione dell'interfaccia utente principale
  /// Struttura: Scaffold con form in ListView
  /// Layout: Progressivo (macrocategoria -> categoria -> dettagli)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('INSERISCI NUOVA PIETANZA'),
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
          child: Consumer<MenuProvider>(
            builder: (context, menuProvider, child) {
              final macrocategorie = menuProvider.macrocategorie;
              
              // Filtra categorie per macrocategoria selezionata
              final List<Categoria> categorieFiltrate = _selectedMacrocategoriaId != null
                  ? menuProvider.categorie.where((c) => c.macrocategoriaId == _selectedMacrocategoriaId).toList()
                  : [];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Sezione 1: Selezione macrocategoria
                      _buildMacrocategorieGrid(macrocategorie),
                      
                      const SizedBox(height: 20),
                      
                      // Sezione 2: Selezione categoria (condizionale)
                      if (_selectedMacrocategoriaId != null) 
                        _buildCategorieSection(categorieFiltrate),
                      
                      const SizedBox(height: 20),
                      
                      // Sezione 3: Dettagli pietanza (condizionale)
                      if (_selectedMacrocategoriaId != null) 
                        _buildPietanzaForm(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // === WIDGET: MACROCATEGORIE GRID ===
  /// Griglia per selezione macrocategoria
  /// Visualizzazione: Card con emoji/nome per ogni macrocategoria
  Widget _buildMacrocategorieGrid(List<Macrocategoria> macrocategorie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Seleziona Macrocategoria *',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Scegli la macrocategoria a cui appartiene la pietanza',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: macrocategorie.length,
          itemBuilder: (context, index) {
            final macrocategoria = macrocategorie[index];
            final isSelected = _selectedMacrocategoriaId == macrocategoria.id;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMacrocategoriaId = macrocategoria.id;
                  _selectedCategoriaId = null; // Reset categoria
                });
              },
              child: Container(
                decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withAlpha((0.3 * 255).round()) : Colors.black.withAlpha((0.7 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.white.withAlpha((0.2 * 255).round()),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Visualizzazione emoji o immagine
                    if (macrocategoria.haFoto)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          macrocategoria.imageUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              macrocategoria.iconaVisualizzata,
                              style: const TextStyle(fontSize: 24),
                            );
                          },
                        ),
                      )
                    else
                      Text(
                        macrocategoria.iconaVisualizzata,
                        style: const TextStyle(fontSize: 24),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      macrocategoria.nome,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // === WIDGET: CATEGORIE SECTION ===
  /// Sezione per selezione categoria (opzionale)
  /// Include opzione "Nessuna Categoria" per pietanze direttamente in macrocategoria
  Widget _buildCategorieSection(List<Categoria> categorie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Seleziona Categoria (Opzionale)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Se la pietanza non appartiene a una categoria specifica, puoi saltare questo passaggio',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        
        // Opzione "Nessuna Categoria"
        Card(
          color: _selectedCategoriaId == null ? Colors.blue.withAlpha((0.2 * 255).round()) : _getCardColor(),
          child: ListTile(
            leading: const Icon(Icons.do_not_disturb, color: Colors.white70),
            title: const Text(
              'Nessuna Categoria',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'La pietanza apparirà direttamente nella macrocategoria',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            trailing: _selectedCategoriaId == null 
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : null,
            onTap: () {
              setState(() {
                _selectedCategoriaId = null;
              });
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Lista categorie disponibili
        if (categorie.isNotEmpty) ...[
          const Text(
            'Categorie disponibili:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...categorie.map((categoria) => Card(
            color: _selectedCategoriaId == categoria.id ? Colors.green.withAlpha((0.2 * 255).round()) : _getCardColor(),
            child: ListTile(
              leading: 
                categoria.haFoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        categoria.imageUrl!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(categoria.iconaVisualizzata);
                        },
                      ),
                    )
                  : Text(categoria.iconaVisualizzata),
              title: Text(
                categoria.nome,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${categoria.pietanze.length} pietanze',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              trailing: _selectedCategoriaId == categoria.id 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCategoriaId = categoria.id;
                });
              },
            ),
          )),
        ] else if (_selectedMacrocategoriaId != null) ...[
          // Messaggio se nessuna categoria disponibile
          Card(
            color: _getCardColor(),
            child: const ListTile(
              leading: Icon(Icons.info, color: Colors.orange),
              title: Text(
                'Nessuna categoria disponibile',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Questa macrocategoria non ha categorie. La pietanza verrà aggiunta direttamente alla macrocategoria.',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // === METODO: GET CARD COLOR ===
  /// Restituisce il colore di default per le card
  Color _getCardColor() {
  return Colors.black.withAlpha((0.7 * 255).round());
  }

  // === WIDGET: PIETANZA FORM ===
  /// Form principale con tutti i dettagli della pietanza
  /// Include: nome, descrizione, prezzo, emoji, foto, allergeni, ingredienti
  Widget _buildPietanzaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Dettagli Pietanza',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Campo nome (obbligatorio)
        _buildTextField(
          controller: _nomeController,
          label: 'Nome Pietanza *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Inserisci il nome della pietanza';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 12),
        
        // Campo descrizione
        _buildTextField(
          controller: _descrizioneController,
          label: 'Descrizione',
          maxLines: 3,
        ),
        
        const SizedBox(height: 12),
        
        // Campo prezzo (obbligatorio)
        _buildTextField(
          controller: _prezzoController,
          label: 'Prezzo (€) *',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Inserisci il prezzo';
            }
            if (double.tryParse(value) == null) {
              return 'Inserisci un prezzo valido';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 12),
        
        // Campo emoji (opzionale)
        _buildTextField(
          controller: _emojiController,
          label: 'Emoji (Opzionale)',
          hintText: 'Inserisci un\'emoji se non vuoi usare una foto',
        ),
        
        const SizedBox(height: 16),
        
        // Sezione foto
        _buildFotoSection(),
        
        const SizedBox(height: 16),
        
        // ✅ NUOVO: Sezione allergeni
        _buildAllergeniSection(),
        
        const SizedBox(height: 16),
        
        // Sezione ingredienti
        const Text(
          'Ingredienti:',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Input ingredienti
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ingredientiController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Aggiungi ingrediente...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withAlpha((0.2 * 255).round())),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withAlpha((0.2 * 255).round())),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _aggiungiIngrediente,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Aggiungi'),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Lista ingredienti aggiunti
        if (_ingredientiList.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ingredientiList.asMap().entries.map((entry) {
              final index = entry.key;
              final ingrediente = entry.value;
              return Chip(
                label: Text(ingrediente, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.orange.withAlpha((0.3 * 255).round()),
                deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                onDeleted: () => _rimuoviIngrediente(index),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Riepilogo anteprima
        Card(
          color: _getCardColor(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riepilogo:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    final macrocategoria = menuProvider.getMacrocategoriaById(_selectedMacrocategoriaId!);
                    final categoria = _selectedCategoriaId != null 
                        ? menuProvider.getCategoriaById(_selectedCategoriaId!)
                        : null;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Macrocategoria: ${macrocategoria?.nome ?? "N/A"} ${macrocategoria?.iconaVisualizzata ?? ""}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Categoria: ${categoria?.nome ?? "Nessuna (direttamente in macrocategoria)"}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (_emojiController.text.isNotEmpty)
                          Text(
                            'Emoji: ${_emojiController.text}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        if (_selectedImageUrl != null)
                          const Text(
                            'Foto: Selezionata',
                            style: TextStyle(color: Colors.white70),
                          ),
                        if (_allergeniList.isNotEmpty)
                          Text(
                            'Allergeni: ${_allergeniList.join(', ')}',
                            style: const TextStyle(color: Colors.orange),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Pulsante salvataggio
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _salvaPietanza,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SALVA PIETANZA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // === WIDGET: ALLERGENI SECTION ===
  /// ✅ NUOVO: Sezione per gestione allergeni
  /// UI: Input text + pulsante aggiungi + chips lista
  Widget _buildAllergeniSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Allergeni (Opzionale)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Seleziona gli allergeni presenti nella pietanza',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        
        // Input allergeni
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _allergeniController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Aggiungi allergene...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withAlpha((0.2 * 255).round())),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withAlpha((0.2 * 255).round())),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _aggiungiAllergene,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Aggiungi'),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Lista allergeni aggiunti
        if (_allergeniList.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergeniList.asMap().entries.map((entry) {
              final index = entry.key;
              final allergene = entry.value;
              return Chip(
                label: Text(allergene, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red.withAlpha((0.3 * 255).round()),
                deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                onDeleted: () => _rimuoviAllergene(index),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  // === WIDGET: FOTO SECTION ===
  /// Sezione per selezione e anteprima foto
  /// Due stati: Selettore foto (se nessuna foto) o Anteprima (se foto selezionata)
  Widget _buildFotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Pietanza (Opzionale)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Se non inserisci un\'emoji, puoi aggiungere una foto della pietanza',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        
        if (_selectedImageUrl != null) 
          _buildFotoPreview()
        else
          _buildFotoSelector(),
      ],
    );
  }

  // === WIDGET: FOTO SELECTOR ===
  /// Interfaccia per selezionare una foto quando non ce n'è una
  Widget _buildFotoSelector() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withAlpha((0.3 * 255).round()),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
  color: Colors.black.withAlpha((0.3 * 255).round()),
      ),
      child: InkWell(
        onTap: _scegliFoto,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: Colors.white.withAlpha((0.7 * 255).round()),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Aggiungi Foto',
              style: TextStyle(
                color: Colors.white.withAlpha((0.7 * 255).round()),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Clicca per selezionare una foto',
              style: TextStyle(
                color: Colors.white.withAlpha((0.5 * 255).round()),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET: FOTO PREVIEW ===
  /// Anteprima foto selezionata con pulsante rimuovi
  Widget _buildFotoPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange.withAlpha((0.5 * 255).round()),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Immagine
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _selectedImageUrl != null
                ? Image.network(
                    _selectedImageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.photo,
                            color: Colors.white54,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.photo,
                        color: Colors.white54,
                        size: 50,
                      ),
                    ),
                  ),
          ),
          
          // Pulsante rimuovi
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.red.withAlpha((0.8 * 255).round()),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: _rimuoviFoto,
              ),
            ),
          ),
          
          // Badge informativo
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.7 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Foto Selezionata',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET BUILDER: TEXT FIELD ===
  /// Builder standardizzato per campi di testo
  /// Parametri: controller, label, hint, keyboard type, validatore
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withAlpha((0.2 * 255).round())),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withAlpha((0.2 * 255).round())),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      validator: validator,
    );
  }
}