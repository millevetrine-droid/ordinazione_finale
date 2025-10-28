import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'package:ordinazione/core/providers/cart_provider.dart';
import 'package:ordinazione/core/providers/menu_provider.dart';
import 'category_expansion_section.dart';

class MenuContent extends StatefulWidget {
  const MenuContent({super.key});

  @override
  State<MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent> {
  final Map<String, bool> _categorieEspanse = {};

  void _toggleCategoria(String categoriaId) {
    setState(() {
      _categorieEspanse[categoriaId] = !(_categorieEspanse[categoriaId] ?? false);
    });
  }

  void _onAddToCart(Pietanza pietanza, BuildContext context) {
    Provider.of<CartProvider>(context, listen: false)
        .aggiungiAlCarrello(pietanza);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pietanza.nome} aggiunto al carrello!'),
        backgroundColor: const Color(0xFFFF6B8B),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final categorie = menuProvider.categorie;

        if (categorie.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, color: Colors.white, size: 64),
                SizedBox(height: 16),
                Text(
                  'Nessuna categoria disponibile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Le categorie del menu appariranno qui',
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
          padding: const EdgeInsets.all(12),
          itemCount: categorie.length,
          itemBuilder: (context, index) {
            final categoria = categorie[index];
            final pietanze = menuProvider.getPietanzeByCategoria(categoria.id);
            final isEspansa = _categorieEspanse[categoria.id] ?? false;

            return CategoryExpansionSection(
              // CORREZIONE: Passa categoria.nome invece dell'oggetto categoria
              categoria: categoria.nome,
              pietanze: pietanze,
              isEspansa: isEspansa,
              onTap: () => _toggleCategoria(categoria.id),
              onAddToCart: (pietanza) => _onAddToCart(pietanza, context),
            );
          },
        );
      },
    );
  }
}