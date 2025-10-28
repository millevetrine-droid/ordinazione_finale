import 'package:flutter/material.dart';
// ✅ CORRETTO PERCORSO
// ✅ CORRETTO PERCORSO
import '../../../features/home/widgets/bottom_nav_bar.dart'; // ✅ CORRETTO PERCORSO
import '../visualizza_cucina_screen.dart';
import '../cameriere_ordine_manuale_screen.dart';
import 'widgets/tab_pietanze_pronte.dart';
import 'widgets/tab_archivio_sala.dart';

class SalaScreen extends StatefulWidget {
  const SalaScreen({super.key});

  @override
  State<SalaScreen> createState() => _SalaScreenState();
}

class _SalaScreenState extends State<SalaScreen> {
  int _currentIndex = 0;
  int _selectedTab = 0;

  void _onTabTapped(int index) => setState(() => _currentIndex = index);

  void _generaQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Colors.black.withAlpha((0.9 * 255).round()),
        title: const Text(
          'Genera QR Code Tavolo',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Inserisci il numero del tavolo per generare il QR code:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Numero Tavolo',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'ANNULLA',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('QR Code generato con successo'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'GENERA QR',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _prendiOrdineManuale(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameriereOrdineManualeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('SALA - Pietanze Pronte da Servire'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisualizzaCucinaScreen()),
              );
            },
            tooltip: 'Vista Cucina',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => _generaQRCode(context),
            tooltip: 'Genera QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _prendiOrdineManuale(context),
            tooltip: 'Ordine Manuale',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Aggiorna ordini',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/splash.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
  color: Colors.black.withAlpha((0.7 * 255).round()),
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
  color: Colors.black.withAlpha((0.8 * 255).round()),
      child: Row(
        children: [
          _buildTabButton(0, 'Pietanze Pronte'),
          _buildTabButton(1, 'Archivio Recuperi'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int tabIndex, String label) {
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => _selectedTab = tabIndex),
        style: TextButton.styleFrom(
          foregroundColor: _selectedTab == tabIndex ? const Color(0xFFFF6B8B) : Colors.white70,
          backgroundColor: _selectedTab == tabIndex ? Colors.black : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: _selectedTab == tabIndex ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return const TabPietanzePronte();
      case 1:
        return const TabArchivioSala();
      default:
        return const TabPietanzePronte();
    }
  }
}