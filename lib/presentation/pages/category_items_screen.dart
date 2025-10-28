import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/models/categoria_model.dart'; // ✅ AGGIUNTO IMPORT
import 'package:ordinazione/core/providers/cart_provider.dart';
import 'package:ordinazione/core/providers/menu_provider.dart';
import 'package:ordinazione/core/providers/session_provider.dart';
import 'package:ordinazione/features/home/widgets/bottom_nav_bar.dart';
import 'package:ordinazione/presentation/widgets/compact_cart_bar.dart';
import 'package:ordinazione/presentation/widgets/pietanza_list_item.dart';
import 'package:ordinazione/presentation/widgets/checkout_dialog.dart';
import 'package:ordinazione/presentation/widgets/cart/cart_detailed_view.dart';

class CategoryItemsScreen extends StatefulWidget {
  final Categoria categoria; // ✅ CAMBIATO DA String A Categoria

  const CategoryItemsScreen({
    super.key,
    required this.categoria, // ✅ CAMBIATO PARAMETRO
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    
    switch (index) {
      case 0: // Home
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1: // Ordina - già in menu
        break;
      case 2: // Ordini
        _mostraFeatureInSviluppo('Gestione Ordini Personali');
        break;
      case 3: // Impostazioni
        _mostraFeatureInSviluppo('Impostazioni');
        break;
    }
  }

  void _mostraFeatureInSviluppo(String nomeFeature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nomeFeature - Feature in sviluppo'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _checkout(BuildContext context) {
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

    if (!sessionProvider.hasSessioneAttiva) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessione non valida. Seleziona un tavolo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.categoria.nome), // ✅ USA categoria.nome
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
          color: Colors.black.withAlpha((0.6 * 255).round()),
          child: Column(
            children: [
              // LISTA PIETANZE
              Expanded(
                child: Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    final pietanze = widget.categoria.pietanze; // ✅ USA pietanze DIRETTAMENTE DALLA CATEGORIA

                    if (pietanze.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, color: Colors.white, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'Nessuna pietanza disponibile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pietanze.length,
                      itemBuilder: (context, index) {
                        final pietanza = pietanze[index];
                        return PietanzaListItem(
                          pietanza: pietanza,
                          onAddToCart: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .aggiungiAlCarrello(pietanza);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${pietanza.nome} aggiunto al carrello!'),
                                backgroundColor: const Color(0xFFFF6B8B),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // CARRELLO COMPATTO IN BASSO
              CompactCartBar(
                onViewCart: () => _mostraCarrelloDettagliato(context),
                onCheckout: () => _checkout(context),
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
}