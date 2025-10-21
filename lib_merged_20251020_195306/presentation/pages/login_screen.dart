import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../features/home/widgets/bottom_nav_bar.dart';
import 'cucina/cucina_screen.dart'; // ✅ CORRETTO PERCORSO
import 'sala/sala_screen.dart';
import 'proprietario_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _currentIndex = 0;
  bool _isLoading = false;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _login(BuildContext context) async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci username e password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!context.mounted) return;

    if (success) {
      _navigateBasedOnRole(authProvider.user!.ruolo, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenziali errate'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateBasedOnRole(String ruolo, BuildContext context) {
    switch (ruolo) {
      case 'cuoco':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CucinaScreen()),
        );
        break;
      case 'cameriere':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SalaScreen()),
        );
        break;
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProprietarioScreen()),
        );
        break;
      default:
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Accesso Staff'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withAlpha((0.6 * 255).round()),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.8 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person,
                      color: Color(0xFFFF6B8B),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ACCESSO STAFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inserisci le tue credenziali',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF6B8B)),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF6B8B)),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    if (_isLoading)
                      const CircularProgressIndicator(
                        color: Color(0xFFFF6B8B),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _login(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B8B),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'ACCEDI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.5 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha((0.1 * 255).round())),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credenziali di test:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '👨‍🍳 Cuoco: cuoco / 123\n'
                            '👨‍💼 Cameriere: cameriere / 123\n'
                            '👑 Admin: admin / 123',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}