import 'package:flutter/material.dart';
// ✅ CORRETTO PERCORSO
import 'widgets/tab_ordini_attivi.dart';
import 'widgets/tab_archivio_recuperi.dart';
import 'package:ordinazione/features/home/widgets/bottom_nav_bar.dart'; // ✅ CORRETTO PERCORSO

class CucinaScreen extends StatefulWidget {
  const CucinaScreen({super.key});

  @override
  State<CucinaScreen> createState() => _CucinaScreenState();
}

class _CucinaScreenState extends State<CucinaScreen> {
  int _currentIndex = 0;
  int _selectedTab = 0;

  void _onTabTapped(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // AppBar rimosso per layout pulito durante i test
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
          _buildTabButton(0, 'Ordini Attivi'),
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
        return const TabOrdiniAttivi();
      case 1:
        return const TabArchivioRecuperi();
      default:
        return const TabOrdiniAttivi();
    }
  }
}