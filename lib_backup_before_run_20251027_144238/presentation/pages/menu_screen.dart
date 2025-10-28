/// FILE: lib/presentation/pages/menu_screen.dart
/// SCOPO: Schermata menu pietanze con funzionalità di ordinazione e checkout
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa: 
///   - 'package:provider/provider.dart' per gestione stato
///   - '../../core/providers/menu_provider.dart' per dati menu
///   - '../../core/providers/cart_provider.dart' per gestione carrello
///   - '../../core/providers/session_provider.dart' per sessione tavolo
///   - '../widgets/checkout_dialog.dart' per dialog checkout
///   - '../widgets/cart/cart_detailed_view.dart' per visualizzazione carrello
/// - Collegato a:
///   - CategoryItemsScreen - schermata dettaglio categoria
///   - SessionProvider - verifica sessione per checkout
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione menu organizzato in macrocategorie e categorie
/// - Navigazione a schermate dettaglio categorie
/// - Gestione carrello e checkout
/// - Verifica sessione tavolo per ordinazione
/// 
/// MODIFICHE APPLICATE:
/// - 2024-01-20 - Aggiunti debug per verificare stato sessione durante checkout
/// - 2024-01-20 - Aggiunti print per troubleshooting sessione tavolo
/// 
/// DA VERIFICARE:
/// - I debug mostrano correttamente lo stato della sessione
/// - La sessione viene riconosciuta dopo selezione tavolo
/// - Il checkout funziona con sessione attiva
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/menu_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/session_provider.dart';
import '../../core/models/categoria_model.dart';
import '../../core/models/macrocategoria_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/compact_cart_bar.dart';
import '../widgets/checkout_dialog.dart';
import '../../features/home/dialogs/selezione_tavolo_dialog.dart';
import '../widgets/cart/cart_detailed_view.dart';
import 'category_items_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  void _checkout(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Il carrello è vuoto!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

      // ✅ DEBUG: Verifica stato sessione
      debugPrint('=== DEBUG CHECKOUT ===');
      debugPrint('Sessione attiva: ${sessionProvider.hasSessioneAttiva}');
      debugPrint('Tavolo corrente: ${sessionProvider.sessioneCorrente?.numeroTavolo}');
      debugPrint('Provider: $sessionProvider');
      debugPrint('=====================');

    if (!sessionProvider.hasSessioneAttiva) {
      // Apri il dialog per selezionare il tavolo direttamente
      final numeroTavolo = await showDialog<String>(
        context: context,
        builder: (context) => SelezioneTavoloDialog(
          onTavoloSelezionato: (numero) {
            Navigator.of(context).pop(numero);
          },
        ),
      );

    if (!context.mounted) return; // guard against context use after await

      if (numeroTavolo != null) {
        final numero = int.tryParse(numeroTavolo);
        if (numero != null) {
          sessionProvider.setTavolo(numero);
        }
      } else {
        // L'utente ha annullato la selezione
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selezione tavolo annullata'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // A questo punto la sessione dovrebbe esistere; apri il dialog di conferma
    showDialog(
      context: context,
      builder: (context) => const CheckoutDialog(),
    );
  }

  void _mostraCarrelloDettagliato(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Il carrello è vuoto!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: CartDetailedView(
          onCheckout: () {
            Navigator.of(context).pop();
            _checkout(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<MenuProvider>(
            builder: (context, menuProvider, child) {
              final macrocategorie = menuProvider.macrocategorie;
              
              // Filtra solo le macrocategorie che hanno categorie con pietanze
              final macrocategorieConCategorie = macrocategorie.where((macrocategoria) {
                final categorie = menuProvider.getCategorieByMacrocategoria(macrocategoria.id);
                return categorie.any((categoria) => categoria.haPietanzeDisponibili);
              }).toList();

              if (macrocategorieConCategorie.isEmpty) {
                return const EmptyState(
                  icon: Icons.restaurant_menu,
                  title: 'Menu vuoto',
                  subtitle: 'Il proprietario sta ancora preparando il menu',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: macrocategorieConCategorie.length,
                itemBuilder: (context, index) {
                  final macrocategoria = macrocategorieConCategorie[index];
                  return _buildMacrocategoriaSection(macrocategoria, menuProvider, context);
                },
              );
            },
          ),
        ),

        CompactCartBar(
          onViewCart: () => _mostraCarrelloDettagliato(context),
          onCheckout: () => _checkout(context),
        ),
      ],
    );
  }

  Widget _buildMacrocategoriaSection(Macrocategoria macrocategoria, MenuProvider menuProvider, BuildContext context) {
    final categorieConPietanze = menuProvider.getCategorieByMacrocategoria(macrocategoria.id)
        .where((categoria) => categoria.haPietanzeDisponibili)
        .toList();
    
    if (categorieConPietanze.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Macrocategoria
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(51),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      macrocategoria.iconaVisualizzata,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    macrocategoria.nome.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categorie della macrocategoria (SOLO quelle con pietanze)
          ...categorieConPietanze.map((categoria) => 
            _buildCategoryItem(categoria, menuProvider, context)
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Categoria categoria, MenuProvider menuProvider, BuildContext context) {
    final numeroPietanzeDisponibili = categoria.pietanzeDisponibili.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              categoria.iconaVisualizzata,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          categoria.nome,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$numeroPietanzeDisponibili ${numeroPietanzeDisponibili == 1 ? 'pietanza' : 'pietanze'} disponibili',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryItemsScreen(categoria: categoria),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}