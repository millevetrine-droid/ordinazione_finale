import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import '../screens/menu_screen.dart';
import '../screens/profilo_cliente_screen.dart';
import '../screens/login_screen.dart';

class GlobalNavigationDrawer extends StatelessWidget {
  final String? numeroTavolo;
  final bool isLoggedIn;
  final String? nomeUtente;
  final int? puntiUtente;
  final String? telefonoUtente;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;

  const GlobalNavigationDrawer({
    super.key,
    this.numeroTavolo,
    this.isLoggedIn = false,
    this.nomeUtente,
    this.puntiUtente,
    this.telefonoUtente,
    this.onLoginTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 👇 HEADER STILE MCDONALD'S
            _buildHeader(context),
            
            // 👇 SEZIONE CLIENTE
            _buildClientSection(context),
            
            // 👇 SEZIONE STAFF (SEMPRE VISIBILE - COME MCDONALD'S)
            _buildStaffSection(context),
            
            // 👇 SEZIONE INFORMAZIONI
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513), // Marrone McDonald's
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacitySafe(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MAGNO RESTAURANT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                if (numeroTavolo != null)
                  Text(
                    'Tavolo $numeroTavolo',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                if (isLoggedIn && nomeUtente != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ciao, $nomeUtente!',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                isLoggedIn ? '${puntiUtente ?? 0} PUNTI' : 'ACCUMULA PUNTI',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'IL TUO ACCOUNT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        
        // ORDINA
        _buildDrawerItem(
          icon: Icons.restaurant,
          title: '🍕 Ordina dal Menu',
          subtitle: 'Sfoglia e ordina le pietanze',
          onTap: () {
            Navigator.pop(context);
            if (numeroTavolo != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuScreen(numeroTavolo: numeroTavolo!),
                ),
              );
            }
          },
        ),
        
        if (isLoggedIn) ...[
          // PROFILO
          _buildDrawerItem(
            icon: Icons.person,
            title: '👤 Profilo Personale',
            subtitle: nomeUtente ?? 'Gestisci il tuo account',
            onTap: () {
              Navigator.pop(context);
              if (telefonoUtente != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfiloClienteScreen(
                      telefonoCliente: telefonoUtente!,
                    ),
                  ),
                );
              }
            },
          ),
          
          // PUNTI
          _buildDrawerItem(
            icon: Icons.loyalty,
            title: '⭐ I Miei Punti',
            subtitle: '$puntiUtente punti accumulati',
            onTap: () {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(const SnackBar(content: Text('Vai alla sezione punti')));
            },
          ),
          
          // STORICO ORDINI
          _buildDrawerItem(
            icon: Icons.history,
            title: '📊 Storico Ordini',
            subtitle: 'I tuoi ordini passati',
              onTap: () {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(const SnackBar(content: Text('Storico ordini - In sviluppo')));
            },
          ),
          
          // REGALA PUNTI
          if ((puntiUtente ?? 0) > 0)
            _buildDrawerItem(
              icon: Icons.card_giftcard,
              title: '🎁 Regala Punti',
              subtitle: 'Condividi con gli amici',
                onTap: () {
                Navigator.pop(context);
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(const SnackBar(content: Text('Regalo punti - In sviluppo')));
              },
            ),
          
          // LOGOUT
          _buildDrawerItem(
            icon: Icons.logout,
            title: '🚪 Esci',
            subtitle: 'Disconnetti account',
              onTap: () {
              Navigator.pop(context);
              onLogoutTap?.call();
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(const SnackBar(content: Text('Arrivederci!')));
            },
            color: Colors.red,
          ),
        ] else ...[
          // LOGIN/REGISTRAZIONE
          _buildDrawerItem(
            icon: Icons.login,
            title: '🔐 Accedi / Registrati',
            subtitle: 'Accumula punti con ogni ordine',
            onTap: () {
              Navigator.pop(context);
              onLoginTap?.call();
            },
            color: const Color(0xFF8B4513),
          ),
        ],
        
        const Divider(height: 20),
      ],
    );
  }

  Widget _buildStaffSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'AREA RISERVATA STAFF',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        
        // CAMERIERE
        _buildDrawerItem(
          icon: Icons.people,
          title: '👨‍💼 Accesso Cameriere',
          subtitle: 'Gestisci ordini sala',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          color: Colors.blue,
        ),
        
        // CUCINA
        _buildDrawerItem(
          icon: Icons.restaurant,
          title: '👨‍🍳 Accesso Cucina',
          subtitle: 'Gestisci ordini cucina',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          color: Colors.green,
        ),
        
        // SALA
        _buildDrawerItem(
          icon: Icons.table_restaurant,
          title: '📋 Accesso Sala',
          subtitle: 'Gestione tavoli e ordini',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          color: Colors.orange,
        ),
        
        // CASSA
        _buildDrawerItem(
          icon: Icons.point_of_sale,
          title: '💰 Accesso Cassa',
          subtitle: 'Gestione pagamenti',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          color: Colors.purple,
        ),
        
        // PROPRIETARIO
        _buildDrawerItem(
          icon: Icons.admin_panel_settings,
          title: '👑 Accesso Proprietario',
          subtitle: 'Gestione completa ristorante',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          color: Colors.red,
        ),
        
        const Divider(height: 20),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'INFORMAZIONI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        
        _buildDrawerItem(
          icon: Icons.help,
          title: '❓ Come Funziona',
          subtitle: 'Guida all\'uso dell\'app',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Guida - In sviluppo')),
            );
          },
        ),
        
        _buildDrawerItem(
          icon: Icons.security,
          title: '🔒 Privacy e Sicurezza',
          subtitle: 'La tua privacy è importante',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy - In sviluppo')),
            );
          },
        ),
        
        _buildDrawerItem(
          icon: Icons.phone,
          title: '📞 Contatti',
          subtitle: 'Assistenza e supporto',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contatti - In sviluppo')),
            );
          },
        ),
        
        _buildDrawerItem(
          icon: Icons.info,
          title: '🏢 Chi Siamo',
          subtitle: 'Il nostro ristorante',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chi siamo - In sviluppo')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? const Color(0xFF8B4513),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}