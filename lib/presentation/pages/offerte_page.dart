import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:ordinazione/core/services/menu_services/menu_service.dart';
import 'package:provider/provider.dart';
// category_items_screen import removed: offers now go straight to cart
import 'package:ordinazione/features/home/widgets/offerta_card.dart' as offerta_widgets;
import 'package:ordinazione/core/providers/cart_provider.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'package:ordinazione/presentation/widgets/cart/cart_detailed_view.dart';

class OffertePage extends StatelessWidget {
  const OffertePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                              const Color(0xFFFF6B8B).withOpacitySafe(0.8),
                              const Color(0xFF4ECDC4).withOpacitySafe(0.6),
                    ],
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      'OFFERTE SPECIALI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Scopri le nostre promozioni esclusive',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista offerte (caricata da MenuService) - now reactive via Stream
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: MenuService().offerteStream,
                  initialData: MenuService().offerteMenu,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Errore caricamento offerte: ${snapshot.error}'));
                    }
          final offerteSpeciali = (snapshot.data ?? [])
            .where((o) => o['attiva'] == true || o['attiva'] == 'true')
            .toList();

                    if (offerteSpeciali.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nessuna offerta disponibile al momento',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: offerteSpeciali.length,
                      itemBuilder: (context, index) {
                        final offerta = offerteSpeciali[index];
                        return offerta_widgets.OffertaCard(
                          titolo: offerta['titolo'] ?? offerta['titolo'] ?? '',
                          descrizione: offerta['sottotitolo'] ?? '',
                          prezzo: (offerta['prezzo'] is num) ? (offerta['prezzo'] as num).toDouble() : double.tryParse(offerta['prezzo']?.toString() ?? '0') ?? 0.0,
                          immagine: offerta['immagine'] ?? '',
              onTap: () async => await _mostraDettaglioOfferta(context, offerta),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostraDettaglioOfferta(BuildContext context, Map<String, dynamic> offerta) async {
    // Convert the offer into a Pietanza-like item and add it to the cart,
    // then open the cart bottom sheet so the customer can return to browsing.
    try {
      final prezzo = (offerta['prezzo'] is num) ? (offerta['prezzo'] as num).toDouble() : double.tryParse(offerta['prezzo']?.toString() ?? '0') ?? 0.0;
      final piet = Pietanza(
        id: 'offerta_${offerta['id'] ?? DateTime.now().millisecondsSinceEpoch}',
        nome: offerta['titolo'] ?? offerta['titolo'] ?? '',
        descrizione: offerta['sottotitolo'] ?? '',
        prezzo: prezzo,
        emoji: offerta['immagine'] ?? offerta['immagine'] ?? '',
        macrocategoriaId: 'offerte',
      );

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.aggiungiAlCarrello(piet);

      // Show cart detailed view as a bottom sheet (same UX as MenuScreen)
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
              // Attempt to follow the MenuScreen behavior: call checkout flow.
              // We simply pop the sheet and let upstream UI handle checkout.
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Errore aggiunta offerta al carrello: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore aggiunta offerta al carrello: $e'), backgroundColor: Colors.red),
      );
    }
  }
}