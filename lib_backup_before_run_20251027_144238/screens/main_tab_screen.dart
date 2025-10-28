import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import 'package:provider/provider.dart';
import 'home_tab_screen.dart';
import 'menu_screen.dart';
import 'points_dashboard_screen.dart';
import 'profile_screen.dart';
import '../state/auth_state.dart';
import '../navigation/global_navigation_drawer.dart';

class MainTabScreen extends StatefulWidget {
  final String numeroTavolo;

  const MainTabScreen({super.key, required this.numeroTavolo});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 1; // Di default parte da "Ordina"
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeTabScreen(numeroTavolo: widget.numeroTavolo),
      MenuScreen(numeroTavolo: widget.numeroTavolo),
      PointsDashboardScreen(numeroTavolo: widget.numeroTavolo),
      ProfileScreen(numeroTavolo: widget.numeroTavolo),
      Container(), // PLACEHOLDER per il tab "Altro"
    ]);
  }

  void _onTabTapped(int index) {
    if (index == 4) {
      _scaffoldKey.currentState?.openDrawer();
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    final isLoggedIn = authState.isLoggedIn;

    return Scaffold(
      key: _scaffoldKey,
      drawer: GlobalNavigationDrawer(
        numeroTavolo: widget.numeroTavolo,
        isLoggedIn: authState.isLoggedIn,
        nomeUtente: authState.currentUser?.nome,
        puntiUtente: authState.currentUser?.punti,
        telefonoUtente: authState.currentUser?.telefono,
        onLoginTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usa il flusso ordine per accedere')),
          );
        },
        onLogoutTap: () {
          authState.logout();
        },
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(isLoggedIn),
    );
  }

  Widget _buildBottomNavBar(bool isLoggedIn) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacitySafe(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF8B4513),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Ordina',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.loyalty_outlined),
            activeIcon: Icon(Icons.loyalty),
            label: 'Punti',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: isLoggedIn ? 'Profilo' : 'Accedi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz),
            label: 'Altro',
          ),
        ],
      ),
    );
  }
}