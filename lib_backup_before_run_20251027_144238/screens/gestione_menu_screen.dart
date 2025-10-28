import 'package:flutter/material.dart';
// replaced direct firestore usage with core FirebaseService accessor (imported below)
import '../models/pietanza_model.dart';
import '../models/categoria_model.dart';
import '../services/firebase_service.dart';
import 'package:ordinazione/core/services/firebase_service.dart' as core_fb;
import 'gestione_categorie_screen.dart';
import 'editor_pietanza_screen.dart';
import 'ordinamento_pietanze_screen.dart';

class GestioneMenuScreen extends StatefulWidget {
  const GestioneMenuScreen({super.key});

  @override
  State<GestioneMenuScreen> createState() => _GestioneMenuScreenState();
}

class _GestioneMenuScreenState extends State<GestioneMenuScreen> {
  final List<Categoria> _macrocategorie = [];
  final Map<String, List<Pietanza>> _pietanzePerCategoria = {};
  String? _categoriaSelezionata;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _caricaMenu();
  }

  void _caricaMenu() {
    if (!mounted) return;
    
    setState(() {
      _macrocategorie.clear();
      _pietanzePerCategoria.clear();
      
      // Carica macrocategorie
      _macrocategorie.addAll(FirebaseService.menu.getMacrocategorie());
      
      // Carica pietanze per ogni categoria (macrocategorie e sottocategorie)
      for (final macro in _macrocategorie) {
        // Pietanze direttamente nella macrocategoria
        final pietanzeMacro = FirebaseService.menu.pietanzeMenu.where((p) => 
          p.categoriaId == macro.id
        ).toList();
        
        if (pietanzeMacro.isNotEmpty) {
          _pietanzePerCategoria[macro.id] = pietanzeMacro;
        }
        
        // Pietanze nelle sottocategorie
        final sottocategorie = FirebaseService.menu.getSottocategorie(macro.id);
        for (final sotto in sottocategorie) {
          final pietanzeSotto = FirebaseService.menu.pietanzeMenu.where((p) => 
            p.categoriaId == sotto.id
          ).toList();
          
          if (pietanzeSotto.isNotEmpty) {
            _pietanzePerCategoria[sotto.id] = pietanzeSotto;
          }
        }
      }
      
      // Seleziona la prima categoria con pietanze
      if (_macrocategorie.isNotEmpty) {
        for (final macro in _macrocategorie) {
          if (_pietanzePerCategoria.containsKey(macro.id)) {
            _categoriaSelezionata = macro.id;
            break;
          }
          
          final sottocategorie = FirebaseService.menu.getSottocategorie(macro.id);
          for (final sotto in sottocategorie) {
            if (_pietanzePerCategoria.containsKey(sotto.id)) {
              _categoriaSelezionata = sotto.id;
              break;
            }
          }
          
          if (_categoriaSelezionata != null) break;
        }
        
        // Se nessuna categoria ha pietanze, seleziona la prima macrocategoria
        _categoriaSelezionata ??= _macrocategorie.first.id;
      }
      
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 GESTIONE MENU'),
        backgroundColor: Colors.deepOrange[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _aggiungiPietanza,
            tooltip: 'Aggiungi pietanza',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _isLoading = true;
              });
              _caricaMenu();
            },
          ),
        ],
        // no child parameter for AppBar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_macrocategorie.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // SELEZIONE CATEGORIA
        _buildSelettoreCategoria(),
        
        // LISTA PIETANZE
        Expanded(
          child: _categoriaSelezionata != null && _pietanzePerCategoria.containsKey(_categoriaSelezionata!)
              ? _buildListaPietanze()
              : _buildCategoriaVuota(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Nessuna categoria creata',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            'Crea prima le categorie per organizzare il menu',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _apriGestioneCategorie,
            icon: const Icon(Icons.category),
            label: const Text('GESTISCI CATEGORIE'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelettoreCategoria() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📁 Seleziona Categoria:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Pulsante gestione categorie
              ActionChip(
                avatar: const Icon(Icons.settings, size: 16),
                label: const Text('Gestisci Categorie'),
                onPressed: _apriGestioneCategorie,
              ),
              // Pulsante ordinamento globale
              ActionChip(
                avatar: const Icon(Icons.sort, size: 16),
                label: const Text('Ordina Pietanze'),
                onPressed: _apriOrdinamentoGlobale,
              ),
              // Categorie
              ..._buildCategorieChips(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategorieChips() {
    final chips = <Widget>[];
    
    for (final macro in _macrocategorie) {
      // Macrocategoria
      chips.add(
        FilterChip(
          label: Text('${macro.immagine} ${macro.nome}'),
          selected: _categoriaSelezionata == macro.id,
          onSelected: (selected) {
            if (selected) {
              if (!mounted) return;
              setState(() {
                _categoriaSelezionata = macro.id;
              });
            }
          },
        )
      );
      
      // Sottocategorie
      final sottocategorie = FirebaseService.menu.getSottocategorie(macro.id);
      for (final sotto in sottocategorie) {
        chips.add(
          FilterChip(
            label: Text('${sotto.immagine} ${sotto.nome}'),
            selected: _categoriaSelezionata == sotto.id,
            onSelected: (selected) {
              if (selected) {
                if (!mounted) return;
                setState(() {
                  _categoriaSelezionata = sotto.id;
                });
              }
            },
          )
        );
      }
    }
    
    return chips;
  }

  Widget _buildListaPietanze() {
    final pietanze = _pietanzePerCategoria[_categoriaSelezionata]!;
    final categoria = FirebaseService.menu.categorieMenu.firstWhere(
      (c) => c.id == _categoriaSelezionata,
      orElse: () => _macrocategorie.first
    );

    return Column(
      children: [
        // Intestazione categoria
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Text(categoria.immagine, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  categoria.nome,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Text('${pietanze.length} pietanze', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        // Lista pietanze
        Expanded(
          child: ReorderableListView(
            onReorder: _onReorderPietanze,
            children: pietanze
                .map((pietanza) => _buildPietanzaCard(pietanza))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPietanzaCard(Pietanza pietanza) {
    return Card(
      key: ValueKey(pietanza.id),
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: ListTile(
        leading: pietanza.usaFoto && pietanza.fotoUrl != null
            ? Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(pietanza.fotoUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    pietanza.immagine,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
        title: Text(pietanza.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('€${pietanza.prezzo.toStringAsFixed(2)}'),
            if (pietanza.descrizione.isNotEmpty)
              Text(pietanza.descrizione, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (pietanza.allergeni.isNotEmpty)
              Text('⚠️ ${pietanza.testoAllergeni}', style: const TextStyle(fontSize: 11, color: Colors.orange)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _modificaPietanza(pietanza),
              tooltip: 'Modifica',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _eliminaPietanza(pietanza),
              tooltip: 'Elimina',
            ),
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaVuota() {
    final categoria = FirebaseService.menu.categorieMenu.firstWhere(
      (c) => c.id == _categoriaSelezionata,
      orElse: () => _macrocategorie.first
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(categoria.immagine, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text(
            'Nessuna pietanza in "${categoria.nome}"',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _aggiungiPietanza,
            icon: const Icon(Icons.add),
            label: const Text('AGGIUNGI PRIMA PIETANZA'),
          ),
        ],
      ),
    );
  }

  void _onReorderPietanze(int oldIndex, int newIndex) async {
    if (_categoriaSelezionata == null) return;
    
    final pietanze = _pietanzePerCategoria[_categoriaSelezionata]!;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final List<Pietanza> nuovePietanze = List.from(pietanze);
    final Pietanza item = nuovePietanze.removeAt(oldIndex);
    nuovePietanze.insert(newIndex, item);

    // Aggiorna ordine
    for (int i = 0; i < nuovePietanze.length; i++) {
      nuovePietanze[i] = nuovePietanze[i].copyWith(ordine: i);
    }

    // Capture messenger before any async gaps
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseService.menu.aggiornaOrdinamentoMenu(nuovePietanze);
      if (mounted) {
        _caricaMenu();
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('❌ Errore: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _apriGestioneCategorie() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GestioneCategorieScreen()),
    ).then((_) {
      if (mounted) {
        _caricaMenu();
      }
    });
  }

  void _apriOrdinamentoGlobale() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const OrdinamentoPietanzeScreen()),
    ).then((_) {
      if (mounted) {
        _caricaMenu();
      }
    });
  }

  void _aggiungiPietanza() {
    String? categoriaDefault;
    if (_categoriaSelezionata != null) {
      final categoria = FirebaseService.menu.categorieMenu.firstWhere(
        (c) => c.id == _categoriaSelezionata,
        orElse: () => _macrocategorie.first
      );
      categoriaDefault = categoria.nome;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorPietanzaScreen(
          categoriaDefault: categoriaDefault ?? 'ANTIPASTI',
        ),
      ),
    ).then((_) {
      if (mounted) {
        _caricaMenu();
      }
    });
  }

  void _modificaPietanza(Pietanza pietanza) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorPietanzaScreen(
          pietanzaEsistente: pietanza,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _caricaMenu();
      }
    });
  }

  void _eliminaPietanza(Pietanza pietanza) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Pietanza'),
        content: Text('Sei sicuro di voler eliminare "${pietanza.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
              onPressed: () async {
              // Capture messenger and navigator before async work
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(context);

              nav.pop();
              try {
                await core_fb.FirebaseService().firestore.collection('pietanze').doc(pietanza.id).delete();
                await FirebaseService.menu.inizializzaMenu();
                if (mounted) {
                  _caricaMenu();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('✅ Pietanza eliminata'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('❌ Errore: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}