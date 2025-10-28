import 'package:ordinazione/models/pietanza_model.dart';

class CartController {
  final Map<String, Map<String, dynamic>> cart = {};
  double totalPrice = 0.0;
  int totalItems = 0;

  void updateQuantity(String itemId, String nome, double prezzo, int newQuantity) {
    if (newQuantity <= 0) {
      cart.remove(itemId);
    } else {
      cart[itemId] = {
        'nome': nome,
        'prezzo': prezzo,
        'quantita': newQuantity,
      };
    }
    _calculateTotal();
  }

  void updateQuantityFromPietanza(Pietanza pietanza, int newQuantity) {
    updateQuantity(pietanza.id, pietanza.nome, pietanza.prezzo, newQuantity);
  }

  void clearCart() {
    cart.clear();
    _calculateTotal();
  }

  void _calculateTotal() {
    totalPrice = 0.0;
    totalItems = 0;

    cart.forEach((key, value) {
      totalPrice += value['prezzo'] * value['quantita'];
      totalItems += (value['quantita'] as int);
    });
  }
}