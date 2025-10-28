/// FILE: ordine_recuperabile_card.dart
/// SCOPO: Widget per visualizzazione ordini recuperabili in cucina (pietanze pronte da recuperare)
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importa:
///   - ordine_model.dart (modello ordine)
///   - pietanza_model.dart (modello pietanza)
///   - ordini_provider.dart (gestione stato ordini)
///   - auth_provider.dart (autenticazione utente)
///   - action_buttons.dart (pulsanti azione standardizzati)
/// - Importato da:
///   - schermate cucina per gestione ordini recuperabili
/// - Dipendenze:
///   - package:flutter/material.dart
///   - package:provider/provider.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Visualizzazione ordini con pietanze pronte da recuperare
/// - Pulsanti azione per recupero pietanze in preparazione
/// - Integrazione con OrdiniProvider per aggiornamenti stato
/// - Timestamp e info tavolo
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIORNATO uso pietanza.iconaVisualizzata invece di pietanza.emoji
/// - 2024-01-20: MANTENUTA logica recupero pietanze esistente
/// 
/// DA VERIFICARE:
/// - Corretta visualizzazione emoji dal modello aggiornato
/// - Funzionamento pulsanti recupero con OrdiniProvider
/// - Sync stato con altre schermate cucina
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ordinazione/core/providers/ordini_provider.dart';
import 'package:ordinazione/core/providers/auth_provider.dart';
import 'package:ordinazione/core/models/ordine_model.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'action_buttons.dart';

// === CLASSE: ORDINE RECUPERABILE CARD ===
// Scopo: Widget per ordini con pietanze pronte che possono essere recuperate in preparazione
// Note: Utilizzato quando una pietanza viene erroneamente segnata come pronta
class OrdineRecuperabileCard extends StatelessWidget {
  final Ordine ordine;

  const OrdineRecuperabileCard({super.key, required this.ordine});

  @override
  Widget build(BuildContext context) {
    // Filtra solo le pietanze pronte (recuperabili)
    final pietanzePronte = ordine.pietanze.where((p) => p.isPronto).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.blue.withAlpha((0.5 * 255).round())),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildPietanzeList(pietanzePronte, context),
            const SizedBox(height: 12),
            _buildTimestamp(),
          ],
        ),
      ),
    );
  }

  // === WIDGET: HEADER ===
  /// Intestazione card con info tavolo e badge stato
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Info tavolo
        Row(
          children: [
            const Icon(Icons.table_restaurant, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tavolo ${ordine.numeroTavolo}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Badge stato
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue),
          ),
          child: const Text(
            'DA RECUPERARE',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // === WIDGET: PIETANZE LIST ===
  /// Lista pietanze pronte con pulsanti recupero
  Widget _buildPietanzeList(List<Pietanza> pietanze, BuildContext context) {
    return Column(
      children: pietanze.map((pietanza) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Emoji pietanza - ✅ CORRETTO: usa iconaVisualizzata
            Text(
              pietanza.iconaVisualizzata, // ✅ CORRETTO: usa getter che restituisce sempre String
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            
            // Nome pietanza
            Expanded(
              child: Text(
                pietanza.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Pulsante recupera
            ActionButtons.buildPulsantePietanza(
              'Recupera',
              Colors.blue,
              () => _recuperaPietanza(ordine, pietanza, context),
            ),
          ],
        ),
      )).toList(),
    );
  }

  // === WIDGET: TIMESTAMP ===
  /// Timestamp ultima modifica ordine
  Widget _buildTimestamp() {
    return Text(
      'Segnato come pronto: ${_formatTime(ordine.timestamp)}',
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
      ),
    );
  }

  // === METODO: RECUPERA PIETANZA ===
  /// Recupera una pietanza pronta rimettendola in preparazione
  /// Logica: Chiama OrdiniProvider per aggiornare stato pietanza
  void _recuperaPietanza(Ordine ordine, Pietanza pietanza, BuildContext context) {
    final ordiniProvider = Provider.of<OrdiniProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    ordiniProvider.recuperaPietanza(
      ordine.id,
      pietanza.id,
      authProvider.user!.username,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pietanza.nome} recuperata in preparazione'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // === METODO: FORMAT TIME ===
  /// Formatta DateTime in stringa ore:minuti
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}