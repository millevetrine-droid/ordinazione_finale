import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:ordinazione/core/services/menu_services/menu_service.dart';
import 'package:ordinazione/presentation/pages/category_items_screen.dart';
import 'package:ordinazione/features/home/widgets/offerta_card.dart' as offerta_widgets;

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

              // Lista offerte (caricata da MenuService)
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: MenuService.getOfferteStatic(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Errore caricamento offerte: ${snapshot.error}'));
                    }
                    final offerteSpeciali = snapshot.data ?? [];

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
    // If the offer links to a category, navigate directly to that category
    final linkTipo = offerta['linkTipo'] as String? ?? '';
    final linkDest = offerta['linkDestinazione'] as String? ?? '';

    if (linkTipo == 'categoria' && linkDest.isNotEmpty) {
      try {
        final menuService = MenuService();
        await menuService.inizializzaMenu();
        final allCats = menuService.categorieMenu;
        // Try several matching strategies: id, exact name (case-insensitive),
        // substring match (name contains linkDest or viceversa).
        final matching = allCats.where((c) {
          final name = c.nome.toLowerCase();
          final key = linkDest.toLowerCase();
          return c.id == linkDest || name == key || name.contains(key) || key.contains(name);
        }).toList();

        if (matching.isNotEmpty) {
          final categoria = matching.first;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryItemsScreen(categoria: categoria)),
          );
          return;
        }
      } catch (e) {
        debugPrint('⚠️ Impossibile navigare direttamente alla categoria dall\'offerta: $e');
        // fallthrough to show dialog
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacitySafe(0.9),
        title: Text(
          offerta['titolo'] ?? '',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offerta['sottotitolo'] ?? '',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if ((offerta['pietanzeIncluse'] as List<dynamic>?) != null) const Text(
                'Include:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...( (offerta['pietanzeIncluse'] as List<dynamic>? ?? []).map((pietanza) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${pietanza.toString()}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ))),
              const SizedBox(height: 16),
              Text(
                'Prezzo: €${((offerta['prezzo'] is num) ? (offerta['prezzo'] as num).toDouble() : double.tryParse(offerta['prezzo']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFF6B8B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Chiudi',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Offerta "${offerta['titolo'] ?? ''}" aggiunta al carrello!'),
                  backgroundColor: const Color(0xFFFF6B8B),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8B),
            ),
            child: const Text(
              'Aggiungi al Carrello',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:ordinazione/core/services/menu_services/menu_service.dart';
import 'package:ordinazione/features/home/widgets/offerta_card.dart' as offerta_widgets;

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

              // Lista offerte (caricata da MenuService)
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: MenuService.getOfferteStatic(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Errore caricamento offerte: ${snapshot.error}'));
                    }
                    final offerteSpeciali = snapshot.data ?? [];

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
                          onTap: () => _mostraDettaglioOfferta(context, offerta),
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

  void _mostraDettaglioOfferta(BuildContext context, Map<String, dynamic> offerta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacitySafe(0.9),
        title: Text(
          offerta['titolo'] ?? '',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offerta['sottotitolo'] ?? '',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if ((offerta['pietanzeIncluse'] as List<dynamic>?) != null) const Text(
                'Include:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...( (offerta['pietanzeIncluse'] as List<dynamic>? ?? []).map((pietanza) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${pietanza.toString()}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ))),
              const SizedBox(height: 16),
              Text(
                'Prezzo: €${((offerta['prezzo'] is num) ? (offerta['prezzo'] as num).toDouble() : double.tryParse(offerta['prezzo']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFF6B8B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Chiudi',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Offerta "${offerta['titolo'] ?? ''}" aggiunta al carrello!'),
                  backgroundColor: const Color(0xFFFF6B8B),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8B),
            ),
            child: const Text(
              'Aggiungi al Carrello',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}