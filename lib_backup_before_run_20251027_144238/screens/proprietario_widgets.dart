import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'cucina_screen.dart';
import 'sala_screen.dart';
import 'cassa_screen.dart';
import 'gestione_menu_screen.dart';
import 'gestione_offerte_screen.dart';
import 'proprietario_archivi.dart';

class ProprietarioWidgets {
  static Widget buildStatCompact(String emoji, String title, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  static Widget buildActionButton(String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacitySafe(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(title, 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle, 
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  static List<Widget> buildActionButtons(BuildContext context) {
    return [
      buildActionButton(
        '👨‍🍳 CUCINA',
        'Gestisci ordini cucina',
        Colors.deepOrange,
        Icons.restaurant_menu,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CucinaScreen())),
      ),
      buildActionButton(
        '💁 SALA',
        'Gestisci consegne',
        Colors.green[700]!,
        Icons.room_service,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaScreen())),
      ),
      buildActionButton(
        '💰 CASSA',
        'Fai i conti',
        Colors.blue[700]!,
        Icons.point_of_sale,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CassaScreen())),
      ),
      buildActionButton(
        '📋 MENU',
        'Gestisci pietanze',
        Colors.purple[700]!,
        Icons.menu_book,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestioneMenuScreen())),
      ),
      buildActionButton(
        '🎁 OFFERTE',
        'Gestisci offerte speciali',
        Colors.pink[700]!,
        Icons.local_offer,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestioneOfferteScreen())),
      ),
      buildActionButton(
        '📊 ARCHIVI',
        'Cucina, Sala, Serale',
        Colors.teal[700]!,
        Icons.analytics,
        () => ProprietarioArchivi.mostraArchivi(context),
      ),
    ];
  }
}