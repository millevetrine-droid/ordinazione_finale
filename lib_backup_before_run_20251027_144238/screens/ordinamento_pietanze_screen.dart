import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import '../models/pietanza_model.dart';
import '../services/firebase_service.dart';

class OrdinamentoPietanzeScreen extends StatefulWidget {
  const OrdinamentoPietanzeScreen({super.key});

  @override
  State<OrdinamentoPietanzeScreen> createState() => _OrdinamentoPietanzeScreenState();
}

class _OrdinamentoPietanzeScreenState extends State<OrdinamentoPietanzeScreen> {
  late List<Pietanza> _pietanzeOrdinabili;

  @override
  void initState() {
    super.initState();
    _pietanzeOrdinabili = List.from(FirebaseService.menu.pietanzeMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('↕️ ORDINAMENTO PIETANZE'),
        backgroundColor: Colors.deepOrange[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _salvaOrdinamento,
            tooltip: 'Salva ordinamento',
          ),
        ],
      ),
      body: _pietanzeOrdinabili.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list, size: 60, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Nessuna pietanza da ordinare', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ReorderableColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              onReorder: _onReorder,
              children: _pietanzeOrdinabili
                  .map((pietanza) => _buildPietanzaDraggable(pietanza))
                  .toList(),
            ),
    );
  }

  Widget _buildPietanzaDraggable(Pietanza pietanza) {
    // Trova la categoria della pietanza
    final categoria = FirebaseService.menu.categorieMenu
        .firstWhere((c) => c.id == pietanza.categoriaId, orElse: () => FirebaseService.menu.categorieMenu.first);

    return Card(
      key: ValueKey(pietanza.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Text(pietanza.immagine, style: const TextStyle(fontSize: 24)),
        title: Text(pietanza.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${categoria.nome} - €${pietanza.prezzo.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.drag_handle, color: Colors.grey),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Pietanza item = _pietanzeOrdinabili.removeAt(oldIndex);
      _pietanzeOrdinabili.insert(newIndex, item);
    });
  }

  void _salvaOrdinamento() async {
    final scaffold = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      await FirebaseService.menu.aggiornaOrdinamentoMenu(_pietanzeOrdinabili);

      scaffold.showSnackBar(
        const SnackBar(
          content: Text('✅ Ordinamento salvato con successo!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      nav.pop();
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}