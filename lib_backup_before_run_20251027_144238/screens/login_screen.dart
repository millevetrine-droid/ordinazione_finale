import 'package:flutter/material.dart';
import 'cucina_screen.dart';
import 'sala_screen.dart';
import 'proprietario_screen.dart';
import 'package:ordinazione/utils/color_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Credenziali predefinite per testing
  final Map<String, Map<String, String>> _users = {
    'cuoco': {
      'username': 'cuoco',
      'password': '123',
      'role': 'cuoco'
    },
    'cameriere': {
      'username': 'cameriere', 
      'password': '123',
      'role': 'cameriere'
    },
    'proprietario': {
      'username': 'admin',
      'password': '123',
      'role': 'proprietario'
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // IMMAGINE DI SFONDO SPLASH.JPG
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                // Fallback se l'immagine non viene caricata
                return Container(
                  color: const Color(0xFF6CC1E6),
                );
              },
            ),
          ),

          // OVERLAY SCURO PER MIGLIORARE LA LEGGIBILITÀ
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacitySafe(0.5),
          ),

          // CONTENUTO PRINCIPALE
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO AREA RISERVATA
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacitySafe(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacitySafe(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 50,
                        color: Color(0xFF5AC8FA),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      '🔐 ACCESSO RISERVATO',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    const Text(
                      'Area riservata al personale autorizzato',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // FORM DI LOGIN
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserisci l\'username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserisci la password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              
                              if (_isLoading)
                                const CircularProgressIndicator()
                              else
                                ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5AC8FA),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'ACCEDI',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // CREDENZIALI DI PROVA
                    Card(
                      color: Colors.white.withOpacitySafe(0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text(
                              'Credenziali di prova:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Cuoco: cuoco / 123\n'
                              'Cameriere: cameriere / 123\n'
                              'Proprietario: admin / 123',
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // BOTTONE INDIETRO
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '← Torna alla Home',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simula un ritardo di rete
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final username = _usernameController.text.trim();
        final password = _passwordController.text.trim();

        String? userRole;
        for (final user in _users.values) {
          if (user['username'] == username && user['password'] == password) {
            userRole = user['role'];
            break;
          }
        }

        if (userRole != null) {
          _redirectToDashboard(userRole);
        } else {
          _showError('Credenziali non valide');
        }
      } catch (e) {
        _showError('Errore durante il login: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _redirectToDashboard(String role) {
    switch (role) {
      case 'cuoco':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CucinaScreen()),
        );
        break;
      case 'cameriere':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SalaScreen()),
        );
        break;
      case 'proprietario':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProprietarioScreen()),
        );
        break;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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