import 'package:flutter/material.dart';
import 'package:ordinazione/models/pietanza_model.dart';
import '../../../models/categoria_model.dart';
import '../../../models/cliente_model.dart';
import '../../order_success_screen.dart';

// Sub-controllers
import 'cart_controller.dart';
import 'auth_controller.dart';
import 'category_controller.dart';

// Import dei dialog
import '../dialogs/order_confirmation_dialog.dart';
import '../dialogs/registrati_accedi_dialog.dart';

class MenuController {
  final String numeroTavolo;
  
  final CartController cartController;
  final AuthController authController;
  final CategoryController categoryController;

  MenuController(this.numeroTavolo)
      : cartController = CartController(),
        authController = AuthController(),
        categoryController = CategoryController();

  void initState() {
    categoryController.initState();
  }

  void dispose() {
    // Pulizia risorse se necessario
  }

  // 👇 METODI DELEGATI PER COMODITÀ
  List<Categoria> getCategoriePerMenu() => categoryController.getCategoriePerMenu();
  List<Pietanza> getPietanzePerCategoria() => categoryController.getPietanzePerCategoria(categoriaSelezionata);

  String? get categoriaSelezionata => categoryController.categoriaSelezionata;
  set categoriaSelezionata(String? value) => categoryController.categoriaSelezionata = value;

  Map<String, Map<String, dynamic>> get cart => cartController.cart;
  double get totalPrice => cartController.totalPrice;
  int get totalItems => cartController.totalItems;

  void updateQuantityFromPietanza(Pietanza pietanza, int newQuantity) {
    cartController.updateQuantityFromPietanza(pietanza, newQuantity);
  }

  // 👇 METODI DEI DIALOG
  void showOrderConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => OrderConfirmationDialog(
        totalPrice: cartController.totalPrice,
        totalItems: cartController.totalItems,
        onNoGrazie: () => _inviaOrdineSenzaPunti(context),
        onSiAccumula: () => _showRegistratiAccediDialog(context),
      ),
    );
  }

  void showLoginDialog(BuildContext context) {
    authController.showLoginDialog(context);
  }

  void apriProfiloCliente(BuildContext context) {
    authController.apriProfiloCliente(context);
  }

  void _inviaOrdineSenzaPunti(BuildContext context) {
    Navigator.of(context).pop();
    _mostraSchermataSuccesso(context, accumulaPunti: false);
  }

  void _showRegistratiAccediDialog(BuildContext context) {
    Navigator.of(context).pop();
    
    showDialog(
      context: context,
      builder: (context) => RegistratiAccediDialog(
        puntiGuadagnati: cartController.totalPrice.toInt(),
        onRegistrati: () {
          Navigator.of(context).pop();
          authController.showRegistrationDialog(context);
        },
        onAccedi: () {
          Navigator.of(context).pop();
          authController.showLoginDialog(context);
        },
      ),
    );
  }

  void _mostraSchermataSuccesso(BuildContext context, {bool accumulaPunti = false, Cliente? user}) {
    final puntiGuadagnati = accumulaPunti ? cartController.totalPrice.toInt() : 0;
    final puntiTotali = user?.punti ?? 0;
    
    cartController.clearCart();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(
          puntiGuadagnati: puntiGuadagnati,
          puntiTotali: puntiTotali + puntiGuadagnati,
          numeroTavolo: numeroTavolo,
          telefonoCliente: user?.telefono,
        ),
      ),
    );
  }
}