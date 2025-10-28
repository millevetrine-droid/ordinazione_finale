import 'package:flutter/material.dart';
import 'package:ordinazione/models/pietanza_model.dart';
import 'package:ordinazione/models/categoria_model.dart';
import 'package:ordinazione/services/firebase_service.dart';

class EditorPietanzaScreen extends StatefulWidget {
  final Pietanza? pietanzaEsistente;
  final String categoriaDefault;

  const EditorPietanzaScreen({
    super.key,
    this.pietanzaEsistente,
    this.categoriaDefault = 'ANTIPASTI',
  });

  @override
  State<EditorPietanzaScreen> createState() => _EditorPietanzaScreenState();
}

class _EditorPietanzaScreenState extends State<EditorPietanzaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _prezzoController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _immagineController = TextEditingController();
  final _allergeniController = TextEditingController();
  
  String? _categoriaSelezionataId;
  String? _categoriaSelezionataNome;
  bool _isLoading = false;
  bool _usaFoto = false;
  final List<Categoria> _tutteLeCategorie = [];

  @override
  void initState() {
    super.initState();
    _caricaCategorie();
    
    if (widget.pietanzaEsistente != null) {
      final p = widget.pietanzaEsistente!;
      _nomeController.text = p.nome;
      _prezzoController.text = p.prezzo.toString();
      _descrizioneController.text = p.descrizione;
      _immagineController.text = p.immagine;
      // allergeni is now List<String>
      _allergeniController.text = p.allergeni.isNotEmpty ? p.allergeni.join(', ') : '';
      _usaFoto = p.usaFoto;
      _categoriaSelezionataId = p.categoriaId;
      _categoriaSelezionataNome = p.categoria;
    } else {
      _immagineController.text = '🍽️';
      // Trova la categoria di default
      final categoriaDefault = _tutteLeCategorie.isNotEmpty 
          ? _tutteLeCategorie.firstWhere(
              (c) => c.nome == widget.categoriaDefault,
              orElse: () => _tutteLeCategorie.first,
            )
          : Categoria(id: 'default', nome: 'ANTIPASTI', ordine: 0, tipo: 'macrocategoria');
      _categoriaSelezionataId = categoriaDefault.id;
      _categoriaSelezionataNome = categoriaDefault.nome;
    }
  }

  void _caricaCategorie() {
    setState(() {
      _tutteLeCategorie.clear();
      _tutteLeCategorie.addAll(FirebaseService.menu.categorieMenu);
    });
  }

  List<Categoria> _getCategorieDisponibili() {
    return _tutteLeCategorie.where((categoria) {
      // Mostra sia macrocategorie che sottocategorie
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categorieDisponibili = _getCategorieDisponibili();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pietanzaEsistente != null ? '✏️ Modifica Pietanza' : '➕ Nuova Pietanza'),
        backgroundColor: Colors.deepOrange[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome pietanza *',
                          icon: Icon(Icons.restaurant),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Inserisci il nome' : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _prezzoController,
                        decoration: const InputDecoration(
                          labelText: 'Prezzo (€) *',
                          icon: Icon(Icons.euro),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value!.isEmpty) return 'Inserisci il prezzo';
                          if (double.tryParse(value) == null) return 'Prezzo non valido';
                          if (double.parse(value) <= 0) return 'Il prezzo deve essere positivo';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Selezione categoria gerarchica
                      DropdownButtonFormField<String>(
                        initialValue: _categoriaSelezionataId,
                        decoration: const InputDecoration(
                          labelText: 'Categoria *',
                          icon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: categorieDisponibili.map((categoria) {
                          final prefix = categoria.isMacrocategoria ? '📁 ' : '📂 ';
                          return DropdownMenuItem(
                            value: categoria.id,
                            child: Text('$prefix${categoria.nome}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final categoriaSelezionata = _tutteLeCategorie.firstWhere((c) => c.id == value);
                            setState(() {
                              _categoriaSelezionataId = value;
                              _categoriaSelezionataNome = categoriaSelezionata.nome;
                            });
                          }
                        },
                        validator: (value) => value == null ? 'Seleziona categoria' : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _descrizioneController,
                        decoration: const InputDecoration(
                          labelText: 'Descrizione (opzionale)',
                          icon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _immagineController,
                        decoration: const InputDecoration(
                          labelText: 'Emoji o icona * (es: 🍕, 🍝)',
                          icon: Icon(Icons.emoji_food_beverage),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Inserisci un\'emoji' : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _allergeniController,
                        decoration: const InputDecoration(
                          labelText: 'Allergeni (opzionale)',
                          icon: Icon(Icons.warning),
                          border: OutlineInputBorder(),
                          helperText: 'Es: Contiene glutine, lattosio, ecc.',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Switch per uso foto
                      SwitchListTile(
                        title: const Text('Usa foto invece di emoji'),
                        subtitle: const Text('Se attivo, verrà mostrata una foto invece dell\'emoji'),
                        value: _usaFoto,
                        onChanged: (value) {
                          setState(() {
                            _usaFoto = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // ANTEPRIMA
                      if (_nomeController.text.isNotEmpty) ...[
                        const Text('ANTEPRIMA:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          child: ListTile(
                            leading: _usaFoto
                                ? Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.photo, color: Colors.grey),
                                  )
                                : Text(
                                    _immagineController.text.isNotEmpty ? _immagineController.text : '🍽️', 
                                    style: const TextStyle(fontSize: 24)
                                  ),
                            title: Text(_nomeController.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('€${_prezzoController.text.isNotEmpty ? double.parse(_prezzoController.text).toStringAsFixed(2) : '0.00'}'),
                                if (_descrizioneController.text.isNotEmpty)
                                  Text(_descrizioneController.text, 
                                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(_categoriaSelezionataNome ?? 'Nessuna categoria',
                                    style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                if (_allergeniController.text.isNotEmpty)
                                  Text('⚠️ ${_allergeniController.text}',
                                      style: const TextStyle(fontSize: 11, color: Colors.orange)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _salvaPietanza,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'SALVA PIETANZA',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _salvaPietanza() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Capture messenger and navigator before async gaps
        final messenger = ScaffoldMessenger.of(context);
        final nav = Navigator.of(context);
        final categoriaSelezionata = _tutteLeCategorie.firstWhere(
          (c) => c.id == _categoriaSelezionataId,
          orElse: () => _tutteLeCategorie.first,
        );

        final nuovaPietanza = Pietanza(
          id: widget.pietanzaEsistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _nomeController.text,
          prezzo: double.parse(_prezzoController.text),
          categoria: categoriaSelezionata.nome, // Nome per compatibilità
          categoriaId: _categoriaSelezionataId!, // ID per gerarchia
      macrocategoriaId: categoriaSelezionata.macrocategoriaId.isNotEmpty
        ? categoriaSelezionata.macrocategoriaId
        : categoriaSelezionata.id,
          descrizione: _descrizioneController.text,
          immagine: _immagineController.text.isNotEmpty ? _immagineController.text : '🍽️',
          ordine: widget.pietanzaEsistente?.ordine ?? FirebaseService.menu.pietanzeMenu.length,
          usaFoto: _usaFoto,
      // Convert comma-separated string to List<String> (use empty list when none)
      allergeni: _allergeniController.text.isNotEmpty
        ? _allergeniController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[],
        );

        await FirebaseService.menu.salvaPietanza(nuovaPietanza);
        await FirebaseService.menu.inizializzaMenu();

        if (mounted) {
          nav.pop();
          messenger.showSnackBar(
            SnackBar(
              content: Text('✅ ${widget.pietanzaEsistente != null ? 'Pietanza modificata' : 'Pietanza aggiunta'}!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text('❌ Errore: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _prezzoController.dispose();
    _descrizioneController.dispose();
    _immagineController.dispose();
    _allergeniController.dispose();
    super.dispose();
  }
}