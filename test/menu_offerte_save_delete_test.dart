import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ordinazione/core/utils/color_utils.dart';

void main() {
  test('salvaOfferta stores color as hex when given a Color', () async {
    final firestore = FakeFirebaseFirestore();

    Future<void> salvaOffertaLike(FirebaseFirestore fs, Map<String, dynamic> offerta) async {
      final offertaData = Map<String, dynamic>.from(offerta);
      if (offertaData['colore'] is Color) {
        offertaData['colore'] = ColorParser.colorToHex(offertaData['colore'] as Color);
      }
      await fs.collection('offerte').doc(offerta['id']).set(offertaData);
    }

    final off = {
      'id': 'o1',
      'titolo': 'Sconto',
      'colore': const Color(0xFF123456),
      'attiva': true,
    };

    await salvaOffertaLike(firestore, off);

    final doc = await firestore.collection('offerte').doc('o1').get();
    expect(doc.exists, true);
    expect(doc.data()!['colore'], '#ff123456');
  });

  test('eliminaOfferta removes document', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('offerte').doc('o2').set({'titolo': 'Tmp', 'attiva': true});

    Future<void> eliminaOffertaLike(FirebaseFirestore fs, String id) async {
      await fs.collection('offerte').doc(id).delete();
    }

    await eliminaOffertaLike(firestore, 'o2');
    final doc = await firestore.collection('offerte').doc('o2').get();
    expect(doc.exists, false);
  });
}
