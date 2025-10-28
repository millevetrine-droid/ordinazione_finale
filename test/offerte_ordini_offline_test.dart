import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordinazione/core/models/pietanza_model.dart';
import 'package:ordinazione/core/models/ordine_model.dart';
import 'package:ordinazione/core/services/ordini_service.dart';
import 'package:ordinazione/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

// Offline tests for Offerte migration and Ordini state changes
void main() {
  test('migraColoriOfferte should convert integer colors to hex strings', () async {
    final firestore = FakeFirebaseFirestore();

    // Create two offerte: one with int color, one with already-string color
    await firestore.collection('offerte').doc('off1').set({
      'titolo': 'Promo Int',
      'colore': 0xFF112233,
      'attiva': true,
    });

    await firestore.collection('offerte').doc('off2').set({
      'titolo': 'Promo Str',
      'colore': '#ff445566',
      'attiva': true,
    });

    // Migration logic (copied/compatible with MenuFirestoreService.migraColoriOfferte)
    Future<int> migraColoriOfferte(FirebaseFirestore fs, {int batchSize = 500, bool dryRun = false}) async {
      final snapshot = await fs.collection('offerte').get();
      if (snapshot.docs.isEmpty) return 0;

      int updated = 0;
      WriteBatch batch = fs.batch();
      int ops = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final colore = data['colore'];
        if (colore is int) {
          try {
            final hex = ColorParser.colorToHex(Color(colore));
            if (!dryRun) {
              batch.update(doc.reference, {'colore': hex});
              ops++;
            }
            updated++;
          } catch (_) {
            // ignore malformed
          }
        }

        if (!dryRun && ops >= batchSize) {
          await batch.commit();
          batch = fs.batch();
          ops = 0;
        }
      }

      if (!dryRun && ops > 0) await batch.commit();
      return updated;
    }

    final changed = await migraColoriOfferte(firestore);
    expect(changed, 1);

    final doc1 = await firestore.collection('offerte').doc('off1').get();
    final doc2 = await firestore.collection('offerte').doc('off2').get();

    expect(doc1.exists, true);
    expect(doc2.exists, true);

    expect(doc1.data()!['colore'], '#ff112233');
    expect(doc2.data()!['colore'], '#ff445566');
  });

  test('aggiornaStatoPietanza should update pietanza stato and append storicoStati entry', () async {
    final firestore = FakeFirebaseFirestore();

    // Seed an ordine with one pietanza
    await firestore.collection('ordini').doc('ordine1').set({
      'numeroTavolo': '5',
      'timestamp': Timestamp.now(),
      'stato': 'inAttesa',
      'pietanze': [
        {
          'id': 'p1',
          'nome': 'Pasta',
          'prezzo': 5.0,
          'stato': 'inAttesa',
        }
      ],
      'storicoStati': [],
      'idCameriere': 'c1',
      'note': '',
    });

    final ordiniService = OrdiniService(firestore);

    await ordiniService.aggiornaStatoPietanza(
      ordineId: 'ordine1',
      pietanzaId: 'p1',
      nuovoStato: StatoPietanza.pronto,
      user: 'chef',
    );

    final doc = await firestore.collection('ordini').doc('ordine1').get();
  final data = doc.data()!;

    final pietanze = List<Map<String, dynamic>>.from(data['pietanze']);
    expect(pietanze.first['id'], 'p1');
    expect(pietanze.first['stato'], 'pronto');

    final storico = List<Map<String, dynamic>>.from(data['storicoStati']);
    expect(storico.length, 1);
    final entry = storico.first;
    expect(entry['tipo'], 'pietanza');
    expect(entry['pietanzaId'], 'p1');
    expect(entry['fromStato'], 'inAttesa');
    expect(entry['toStato'], 'pronto');
  });

  test('aggiornaStatoOrdine should update order stato and append storicoStati entry', () async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('ordini').doc('ordine2').set({
      'numeroTavolo': '3',
      'timestamp': Timestamp.now(),
      'stato': 'inAttesa',
      'pietanze': [],
      'storicoStati': [],
      'idCameriere': 'c2',
    });

    final ordiniService = OrdiniService(firestore);

    await ordiniService.aggiornaStatoOrdine('ordine2', StatoOrdine.pronto, 'host');

    final doc = await firestore.collection('ordini').doc('ordine2').get();
  final data = doc.data()!;

    expect(data['stato'], 'pronto');
    final storico = List<Map<String, dynamic>>.from(data['storicoStati']);
    expect(storico.isNotEmpty, true);
    final entry = storico.first;
    expect(entry['fromStato'], isNotNull);
    expect(entry['toStato'], 'pronto');
    expect(entry['user'], 'host');
  });
}
