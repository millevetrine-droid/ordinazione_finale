import 'package:flutter/material.dart';
import '../../../../core/services/firebase_service.dart';
import '../../models/cliente_model.dart';

class RegaloPuntiScreen extends StatefulWidget {
  final String telefonoCliente;
  final String nomeCliente;
  final int puntiDisponibili;

  const RegaloPuntiScreen({
    super.key,
    required this.telefonoCliente,
    required this.nomeCliente,
    required this.puntiDisponibili,
  });

  @override
  State<RegaloPuntiScreen> createState() => _RegaloPuntiScreenState();
}

class _RegaloPuntiScreenState extends State<RegaloPuntiScreen> {
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _puntiController = TextEditingController();
  final TextEditingController _messaggioController = TextEditingController();
  
  Cliente? _clienteTrovato;
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _puntiController.addListener(_aggiornaControlli);
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _puntiController.dispose();
    _messaggioController.dispose();
    super.dispose();
  }

  void _aggiornaControlli() {
    setState(() {});
  }

  void _cercaCliente() async {
    final telefono = _telefonoController.text.trim();
    
    if (telefono.isEmpty || telefono.length < 3) {
      setState(() {
        _clienteTrovato = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _clienteTrovato = null;
    });

    final clienteMap = await FirebaseService.clientAuth.getClienteByTelefono(telefono);
    Cliente? cliente;
    if (clienteMap != null) {
      cliente = Cliente.fromMap(clienteMap, clienteMap['id'] ?? '');
    }
    
    setState(() {
      _clienteTrovato = cliente;
      _isSearching = false;
    });
  }

  void _pulisciRicerca() {
    setState(() {
      _telefonoController.clear();
      _clienteTrovato = null;
    });
  }

  Future<void> _confermaRegalo() async {
    if (_clienteTrovato == null) {
      _mostraErrore('Prima cerca e seleziona un cliente');
      return;
    }

    final punti = int.tryParse(_puntiController.text) ?? 0;
    if (punti <= 0) {
      _mostraErrore('Inserisci un numero di punti valido');
      return;
    }

    if (punti > widget.puntiDisponibili) {
      _mostraErrore('Punti insufficienti. Hai ${widget.puntiDisponibili} punti');
      return;
    }

    if (_clienteTrovato!.telefono == widget.telefonoCliente) {
      _mostraErrore('Non puoi regalare punti a te stesso');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final scaffold = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final risultato = await FirebaseService.points.regalaPunti(
      daTelefono: widget.telefonoCliente,
      aTelefono: _clienteTrovato!.telefono,
      punti: punti,
      messaggio: _messaggioController.text.isNotEmpty ? _messaggioController.text : null,
    );

    setState(() {
      _isLoading = false;
    });

    if (risultato['success'] == true) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(risultato['messaggio'] as String),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      navigator.pop(true);
    } else {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(risultato['error'] as String),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _mostraErrore(String errore) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(errore),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puntiInseriti = int.tryParse(_puntiController.text) ?? 0;
    final puntiRimanenti = widget.puntiDisponibili - puntiInseriti;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 Regala Punti'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ciao ${widget.nomeCliente}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Punti disponibili: ${widget.puntiDisponibili}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Inserisci il numero di telefono del destinatario:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Es: 3331234567',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _telefonoController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _pulisciRicerca,
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.length >= 10) {
                        _cercaCliente();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _cercaCliente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cerca'),
                ),
              ],
            ),

            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 8),
                    Text('Ricerca in corso...'),
                  ],
                ),
              )
            else if (_clienteTrovato != null)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _clienteTrovato!.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _clienteTrovato!.telefono,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '${_clienteTrovato!.punti} punti',
                              style: const TextStyle(
                                color: Color(0xFF8B4513),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: _pulisciRicerca,
                        tooltip: 'Cambia destinatario',
                      ),
                    ],
                  ),
                ),
              )
            else if (_telefonoController.text.isNotEmpty && !_isSearching)
              const Card(
                color: Color(0xFFFFEBEE),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Nessun cliente trovato con questo telefono'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            const Text(
              'Quanti punti vuoi regalare?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _puntiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Inserisci i punti...',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'punti',
              ),
            ),

            if (puntiInseriti > 0) ...[
              const SizedBox(height: 8),
              Text(
                puntiRimanenti >= 0
                    ? '✅ Ti rimarranno $puntiRimanenti punti'
                    : '❌ Punti insufficienti!',
                style: TextStyle(
                  color: puntiRimanenti >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 20),

            const Text(
              'Messaggio (opzionale)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messaggioController,
              decoration: InputDecoration(
                hintText: 'Aggiungi un messaggio...',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_clienteTrovato != null && 
                           puntiInseriti > 0 && 
                           puntiInseriti <= widget.puntiDisponibili && 
                           !_isLoading)
                    ? _confermaRegalo
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'CONFERMA REGALO 🎁',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
