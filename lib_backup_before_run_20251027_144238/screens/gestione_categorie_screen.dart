import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import '../models/categoria_model.dart';
import '../services/firebase_service.dart';

class GestioneCategorieScreen extends StatefulWidget {
  const GestioneCategorieScreen({super.key});

  @override
  State<GestioneCategorieScreen> createState() => _GestioneCategorieScreenState();
}

class _GestioneCategorieScreenState extends State<GestioneCategorieScreen> {
  final List<Categoria> _macrocategorie = [];
  final Map<String, List<Categoria>> _sottocategoriePerMacro = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _caricaCategorie();
  }

  void _caricaCategorie() {
    setState(() {
      _macrocategorie.clear();
      _sottocategoriePerMacro.clear();
      
      // Carica macrocategorie
      _macrocategorie.addAll(FirebaseService.menu.getMacrocategorie());
      
      // Carica sottocategorie per ogni macrocategoria
      for (final macro in _macrocategorie) {
        _sottocategoriePerMacro[macro.id] = FirebaseService.menu.getSottocategorie(macro.id);
      }
      
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📁 GESTIONE CATEGORIE'),
        backgroundColor: Colors.deepOrange[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _aggiungiMacrocategoria,
            tooltip: 'Aggiungi macrocategoria',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _caricaCategorie();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _macrocategorie.isEmpty
              ? _buildEmptyState()
              : ReorderableColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  onReorder: _onReorderMacrocategorie,
                  children: _macrocategorie
                      .map((macro) => _buildMacrocategoriaCard(macro))
                      .toList(),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Nessuna categoria creata',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _aggiungiMacrocategoria,
            icon: const Icon(Icons.add),
            label: const Text('CREA PRIMA CATEGORIA'),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrocategoriaCard(Categoria macro) {
    final sottocategorie = _sottocategoriePerMacro[macro.id] ?? [];
    
    return Card(
      key: ValueKey(macro.id),
      margin: const EdgeInsets.all(8),
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTESTAZIONE MACROCATEGORIA
            Row(
              children: [
                Text(macro.immagine, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    macro.nome,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => _handleMacroMenuAction(value, macro),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'aggiungi_sottocategoria',
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Aggiungi sottocategoria'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'modifica',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Modifica'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'elimina',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Elimina'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // SOTTOCATEGORIE
            if (sottocategorie.isNotEmpty) ...[
              const Text(
                'Sottocategorie:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ReorderableColumn(
                onReorder: (oldIndex, newIndex) => _onReorderSottocategorie(macro.id, oldIndex, newIndex),
                children: sottocategorie
                    .map((sotto) => _buildSottocategoriaCard(sotto))
                    .toList(),
              ),
            ],

            // PULSANTE AGGIUNGI SOTTOCATEGORIA
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _aggiungiSottocategoria(macro),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Aggiungi sottocategoria'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSottocategoriaCard(Categoria sotto) {
    final numeroPietanze = FirebaseService.menu.getPietanzeByCategoria(sotto.id).length;
    
    return Card(
      key: ValueKey(sotto.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      child: ListTile(
  leading: Text(sotto.immagine, style: const TextStyle(fontSize: 20)),
        title: Text(sotto.nome),
        subtitle: Text('$numeroPietanze pietanze'),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          onSelected: (value) => _handleSottoMenuAction(value, sotto),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'modifica',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Modifica'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'elimina',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Elimina'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onReorderMacrocategorie(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final List<Categoria> nuoveMacro = List.from(_macrocategorie);
    final Categoria item = nuoveMacro.removeAt(oldIndex);
    nuoveMacro.insert(newIndex, item);

    // Aggiorna ordine
    for (int i = 0; i < nuoveMacro.length; i++) {
      nuoveMacro[i] = nuoveMacro[i].copyWith(ordine: i);
    }

  final scaffold = ScaffoldMessenger.of(context);
  try {
    await FirebaseService.menu.aggiornaOrdinamentoCategorie(nuoveMacro);
    _caricaCategorie();
  } catch (e) {
    scaffold.showSnackBar(
          SnackBar(
            content: Text('❌ Errore: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void _onReorderSottocategorie(String idMacro, int oldIndex, int newIndex) async {
    final sottocategorie = _sottocategoriePerMacro[idMacro]!;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final List<Categoria> nuoveSotto = List.from(sottocategorie);
    final Categoria item = nuoveSotto.removeAt(oldIndex);
    nuoveSotto.insert(newIndex, item);

    // Aggiorna ordine
    for (int i = 0; i < nuoveSotto.length; i++) {
      nuoveSotto[i] = nuoveSotto[i].copyWith(ordine: i);
    }

  final scaffold = ScaffoldMessenger.of(context);
  try {
    await FirebaseService.menu.aggiornaOrdinamentoCategorie(nuoveSotto);
    _caricaCategorie();
  } catch (e) {
    scaffold.showSnackBar(
          SnackBar(
            content: Text('❌ Errore: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void _handleMacroMenuAction(String action, Categoria macro) {
    switch (action) {
      case 'aggiungi_sottocategoria':
        _aggiungiSottocategoria(macro);
        break;
      case 'modifica':
        _modificaCategoria(macro);
        break;
      case 'elimina':
        _eliminaCategoria(macro);
        break;
    }
  }

  void _handleSottoMenuAction(String action, Categoria sotto) {
    switch (action) {
      case 'modifica':
        _modificaCategoria(sotto);
        break;
      case 'elimina':
        _eliminaCategoria(sotto);
        break;
    }
  }

  void _aggiungiMacrocategoria() {
    _mostraEditorCategoria(null, 'macrocategoria');
  }

  void _aggiungiSottocategoria(Categoria macro) {
    _mostraEditorCategoria(null, 'sottocategoria', macroPadre: macro);
  }

  void _modificaCategoria(Categoria categoria) {
  _mostraEditorCategoria(categoria, categoria.tipo ?? 'macrocategoria');
  }

  void _eliminaCategoria(Categoria categoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Categoria'),
        content: Text('Sei sicuro di voler eliminare "${categoria.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              try {
                    await FirebaseService.menu.eliminaCategoria(categoria.id);
                    _caricaCategorie();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('✅ Categoria eliminata'),
                        backgroundColor: Colors.green,
                      ),
                    );
              } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('❌ $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }

  void _mostraEditorCategoria(Categoria? categoriaEsistente, String tipo, {Categoria? macroPadre}) {
    showDialog(
      context: context,
      builder: (context) => CategoriaEditorDialog(
        categoriaEsistente: categoriaEsistente,
        tipo: tipo,
        macroPadre: macroPadre,
        onSaved: _caricaCategorie,
      ),
    );
  }
}

class CategoriaEditorDialog extends StatefulWidget {
  final Categoria? categoriaEsistente;
  final String tipo;
  final Categoria? macroPadre;
  final VoidCallback onSaved;

  const CategoriaEditorDialog({
    super.key,
    this.categoriaEsistente,
    required this.tipo,
    this.macroPadre,
    required this.onSaved,
  });

  @override
  State<CategoriaEditorDialog> createState() => _CategoriaEditorDialogState();
}

class _CategoriaEditorDialogState extends State<CategoriaEditorDialog> {
  final _nomeController = TextEditingController();
  final _emojiController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoriaEsistente != null) {
      _nomeController.text = widget.categoriaEsistente!.nome;
    _emojiController.text = widget.categoriaEsistente!.immagine;
    } else {
      // Emoji di default in base al tipo
      _emojiController.text = widget.tipo == 'macrocategoria' ? '📁' : '📂';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.categoriaEsistente != null ? 'Modifica Categoria' : 'Nuova Categoria'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.tipo == 'sottocategoria' && widget.macroPadre != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Macrocategoria: ${widget.macroPadre!.nome}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome categoria',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emojiController,
            decoration: const InputDecoration(
              labelText: 'Emoji (es: 🍕, 🍝)',
              border: OutlineInputBorder(),
              helperText: 'Inserisci un\'emoji rappresentativa',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ANNULLA'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvaCategoria,
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('SALVA'),
        ),
      ],
    );
  }

  void _salvaCategoria() async {
    if (_nomeController.text.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Inserisci un nome per la categoria')),
      );
      return;
    }

    setState(() => _isLoading = true);
    // Capture messenger before async gap
    final messenger = ScaffoldMessenger.of(context);

    try {
      final nuovaCategoria = Categoria(
        id: widget.categoriaEsistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text,
        ordine: widget.categoriaEsistente?.ordine ?? FirebaseService.menu.getMacrocategorie().length,
        immagine: _emojiController.text.isNotEmpty ? _emojiController.text : null,
        tipo: widget.tipo,
        idPadre: widget.tipo == 'sottocategoria' ? widget.macroPadre!.id : null,
      );

      await FirebaseService.menu.salvaCategoria(nuovaCategoria);
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSaved();

      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ ${widget.tipo == 'macrocategoria' ? 'Macrocategoria' : 'Sottocategoria'} salvata!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emojiController.dispose();
    super.dispose();
  }
}