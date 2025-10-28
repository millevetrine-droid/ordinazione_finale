import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'archivio_cucina_screen.dart';
import 'archivio_sala_screen.dart';
import 'archivio_serale_screen.dart';

class ProprietarioArchivi {
  static void mostraArchivi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📊 SCEGLI ARCHIVIO', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            _buildArchivioOption(
              context,
              '📚 Archivio Cucina',
              'Pietanze pronte',
              Colors.deepOrange,
              Icons.restaurant_menu,
              () => Navigator.push(context, 
                  MaterialPageRoute(builder: (_) => const ArchivioCucinaScreen())),
            ),
            _buildArchivioOption(
              context,
              '📚 Archivio Sala', 
              'Pietanze consegnate',
              Colors.green,
              Icons.room_service,
              () => Navigator.push(context, 
                  MaterialPageRoute(builder: (_) => const ArchivioSalaScreen())),
            ),
            _buildArchivioOption(
              context,
              '📈 Archivio Serale',
              'Statistiche e incassi',
              Colors.blue,
              Icons.analytics,
              () => Navigator.push(context, 
                  MaterialPageRoute(builder: (_) => const ArchivioSeraleScreen())),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULLA'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildArchivioOption(BuildContext context, String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacitySafe(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}