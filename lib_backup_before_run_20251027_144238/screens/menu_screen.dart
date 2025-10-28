import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/utils/color_utils.dart';
import '../services/firebase_service.dart';
import '../models/pietanza_model.dart';
import '../models/categoria_model.dart';
import 'order_success_screen.dart';
import '../navigation/global_navigation_drawer.dart';
import '../state/auth_state.dart';

// Import dei TUOI componenti esistenti
import 'menu/widgets/menu_header.dart';
import 'menu/widgets/cart_summary.dart';
import 'menu/widgets/empty_state.dart';
import 'menu/widgets/category_tab_bar.dart'; // 👈 CAMBIATO: usa CategoryTabBar invece di CategoryFilter
import 'menu/widgets/menu_item_card.dart';

class MenuScreen extends StatefulWidget {
  final String numeroTavolo;

  const MenuScreen({super.key, required this.numeroTavolo});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // auth-related temporary maps removed (not used here)
  String? _categoriaSelezionata;

  // Carrello
  final Map<String, Map<String, dynamic>> _cart = {};
  double _totalPrice = 0.0;
  int _totalItems = 0;

  // Ottiene le categorie principali per il menu cliente
  List<Categoria> _getCategoriePerMenu() {
    final macrocategorie = FirebaseService.menu.getMacrocategorie();
    final categorieConPietanze = <Categoria>[];

    for (final macro in macrocategorie) {
      final pietanzeMacro = FirebaseService.menu.pietanzeMenu.where((p) => p.categoriaId == macro.id).toList();
      if (pietanzeMacro.isNotEmpty) {
        categorieConPietanze.add(macro);
      }

      final sottocategorie = FirebaseService.menu.getSottocategorie(macro.id);
      for (final sotto in sottocategorie) {
        final pietanzeSotto = FirebaseService.menu.pietanzeMenu.where((p) => p.categoriaId == sotto.id).toList();
        if (pietanzeSotto.isNotEmpty) {
          categorieConPietanze.add(sotto);
        }
      }
    }

    return categorieConPietanze;
  }

  // Ottiene le pietanze per la categoria selezionata
  List<Pietanza> _getPietanzePerCategoria() {
    if (_categoriaSelezionata == null) {
      return FirebaseService.menu.pietanzeMenu;
    }
    return FirebaseService.menu.pietanzeMenu.where((p) => p.categoriaId == _categoriaSelezionata).toList();
  }

  @override
  void initState() {
    super.initState();
    final categorie = _getCategoriePerMenu();
    if (categorie.isNotEmpty) {
      _categoriaSelezionata = categorie.first.id;
    }
  }

  // 👇 METODI PER IL CARRELLO
  void _updateQuantity(String itemId, String nome, double prezzo, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cart.remove(itemId);
      } else {
        _cart[itemId] = {
          'nome': nome,
          'prezzo': prezzo,
          'quantita': newQuantity,
        };
      }
      _calculateTotal();
    });
  }

  void _updateQuantityFromPietanza(Pietanza pietanza, int newQuantity) {
    _updateQuantity(pietanza.id, pietanza.nome, pietanza.prezzo, newQuantity);
  }

  void _calculateTotal() {
    _totalPrice = 0.0;
    _totalItems = 0;

    _cart.forEach((key, value) {
      _totalPrice += value['prezzo'] * value['quantita'];
      _totalItems += (value['quantita'] as int);
    });
  }

  // 👇 METODI PER I DIALOG (semplificati)
  void _showOrderConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Ordine'),
        content: Text('Totale: €${_totalPrice.toStringAsFixed(2)}\n\nVuoi accumulare punti?'),
        actions: [
          TextButton(
            onPressed: () => _inviaOrdineSenzaPunti(),
            child: const Text('NO GRAZIE'),
          ),
          ElevatedButton(
            onPressed: () => _inviaOrdineConPunti(),
            child: const Text('ACCUMULA PUNTI'),
          ),
        ],
      ),
    );
  }

  void _inviaOrdineSenzaPunti() {
    Navigator.of(context).pop();
    _mostraSchermataSuccesso(accumulaPunti: false);
  }

  void _inviaOrdineConPunti() {
    Navigator.of(context).pop();
    _mostraSchermataSuccesso(accumulaPunti: true);
  }

  void _mostraSchermataSuccesso({bool accumulaPunti = false}) {
    final puntiGuadagnati = accumulaPunti ? _totalPrice.toInt() : 0;
    
    setState(() {
      _cart.clear();
      _calculateTotal();
    });
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(
          puntiGuadagnati: puntiGuadagnati,
          puntiTotali: puntiGuadagnati, // Modifica questo con la logica reale
          numeroTavolo: widget.numeroTavolo,
          telefonoCliente: null, // Modifica questo con la logica reale
        ),
      ),
    );
  }

  void _apriProfiloCliente() {
    // Implementazione semplificata
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profilo Cliente'),
        content: const Text('Funzionalità in sviluppo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLoginTap() {
    // Implementazione semplificata
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login'),
        content: const Text('Funzionalità in sviluppo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogoutTap() {
    final authState = Provider.of<AuthState>(context, listen: false);
    authState.logout();
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    final categorie = _getCategoriePerMenu();
    final pietanze = _getPietanzePerCategoria();

    return Scaffold(
      drawer: GlobalNavigationDrawer(
        numeroTavolo: widget.numeroTavolo,
        isLoggedIn: authState.isLoggedIn,
        nomeUtente: authState.currentUser?.nome,
        puntiUtente: authState.currentUser?.punti,
        telefonoUtente: authState.currentUser?.telefono,
        onLoginTap: _handleLoginTap,
        onLogoutTap: _handleLogoutTap,
      ),
      appBar: MenuHeader(
        numeroTavolo: widget.numeroTavolo,
        onProfilePressed: _apriProfiloCliente,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
                child: Container(
                  color: Colors.black.withOpacitySafe(0.6),
          child: Column(
            children: [
              // Carrello - TUO COMPONENTE
              CartSummary(
                numeroTavolo: widget.numeroTavolo,
                cart: _cart,
                totalItems: _totalItems,
                totalPrice: _totalPrice,
                onUpdateQuantity: _updateQuantityFromPietanza,
                onConfirmOrder: _totalItems > 0 ? _showOrderConfirmationDialog : () {},
              ),
              
              // 👇 CAMBIATO: usa CategoryTabBar invece di CategoryFilter
              CategoryTabBar(
                categorie: categorie,
                categoriaSelezionata: _categoriaSelezionata,
                onCategoriaChanged: (categoriaId) {
                  setState(() {
                    _categoriaSelezionata = categoriaId;
                  });
                },
              ),
              
              // Lista prodotti - TUO COMPONENTE
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: pietanze.isEmpty
                      ? EmptyState(categoriaSelezionata: _categoriaSelezionata)
                      : ListView.builder(
                          itemCount: pietanze.length,
                          itemBuilder: (context, index) {
                            final pietanza = pietanze[index];
                            return MenuItemCard(
                              pietanza: pietanza,
                              quantita: _cart[pietanza.id]?['quantita'] ?? 0,
                              onUpdateQuantity: _updateQuantity,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}