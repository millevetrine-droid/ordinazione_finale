import 'package:flutter/material.dart';
import '../../../core/services/firebase_service.dart';
import '../../models/cliente_model.dart';
import '../../models/regalo_punti_model.dart';
import 'regalo_punti_screen.dart';

class ProfiloClienteScreen extends StatefulWidget {
  final String telefonoCliente;

  const ProfiloClienteScreen({
    super.key,
    required this.telefonoCliente,
  });

  @override
  State<ProfiloClienteScreen> createState() => _ProfiloClienteScreenState();
}

class _ProfiloClienteScreenState extends State<ProfiloClienteScreen> {
  Cliente? _cliente;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _caricaProfiloCliente();
  }

  void _caricaProfiloCliente() async {
    try {
      final clienteMap = await FirebaseService.clientAuth.getClienteByTelefono(widget.telefonoCliente);
      if (!mounted) return;
      setState(() {
        _cliente = clienteMap != null ? Cliente.fromMap(clienteMap, clienteMap['id'] ?? '') : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Errore caricamento profilo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 PROFILO CLIENTE'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cliente == null
              ? _buildProfiloNonTrovato()
              : _buildProfiloCompleto(_cliente!),
    );
  }

  Widget _buildProfiloNonTrovato() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Profilo non trovato',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Torna indietro'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfiloCompleto(Cliente cliente) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF8B4513),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cliente.nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📱 ${cliente.telefono}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFEC8B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PUNTI FEDELTÀ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                            Text(
                              'Accumula e sblocca premi!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B4513),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${cliente.punti} PTS',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🚀 AZIONI RAPIDE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (cliente.punti > 0)
                        ActionChip(
                          avatar: const Icon(Icons.card_giftcard, color: Colors.white),
                          label: const Text('Regala Punti', style: TextStyle(color: Colors.white)),
                          backgroundColor: const Color(0xFF8B4513),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RegaloPuntiScreen(
                                  telefonoCliente: cliente.telefono,
                                  nomeCliente: cliente.nome,
                                  puntiDisponibili: cliente.punti,
                                ),
                              ),
                            ).then((_) => _caricaProfiloCliente());
                          },
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.history, color: Colors.white),
                        label: const Text('Storico Ordini', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.blue,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funzionalità in sviluppo')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎁 REGALI INVIATI',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<RegaloPunti>>(
                    stream: FirebaseService.points.getRegaliInviati(widget.telefonoCliente).map((list) => list.map((item) => RegaloPunti.fromMap({'id': item['id'], ...item})).toList()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final regali = snapshot.data ?? [];

                      if (regali.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Non hai ancora regalato punti',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Column(
                        children: regali.take(3).map((regalo) => ListTile(
                          leading: const Icon(Icons.card_giftcard, color: Colors.green),
                          title: Text('A: ${regalo.aNome}'),
                          subtitle: Text('${regalo.punti} punti - ${_formatTime(regalo.data)}'),
                          trailing: Text(regalo.stato, style: TextStyle(
                            color: regalo.stato == 'completato' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          )),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎁 REGALI RICEVUTI',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<RegaloPunti>>(
                    stream: FirebaseService.points.getRegaliRicevuti(widget.telefonoCliente).map((list) => list.map((item) => RegaloPunti.fromMap({'id': item['id'], ...item})).toList()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final regali = snapshot.data ?? [];

                      if (regali.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Non hai ancora ricevuto punti',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Column(
                        children: regali.take(3).map((regalo) => ListTile(
                          leading: const Icon(Icons.redeem, color: Colors.blue),
                          title: Text('Da: ${regalo.daNome}'),
                          subtitle: Text('${regalo.punti} punti - ${_formatTime(regalo.data)}'),
                          trailing: Text('+${regalo.punti}', style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // _buildStatistica was removed because it was unused during migration.

  String _formatTime(DateTime data) {
    return '${data.day}/${data.month}/${data.year}';
  }
}
