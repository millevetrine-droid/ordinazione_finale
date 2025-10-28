import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ordinazione/core/services/point_service.dart';

void main() {
  group('PointsService offline smoke', () {
    test('regalaPunti moves points and writes regaliPunti doc', () async {
      final firestore = FakeFirebaseFirestore();

      // Seed two clients
      await firestore.collection('clienti').doc('c1').set({
        'nome': 'Alice',
        'telefono': '111',
        'punti': 100,
      });

      await firestore.collection('clienti').doc('c2').set({
        'nome': 'Bob',
        'telefono': '222',
        'punti': 10,
      });

      final service = PointsService(firestore);

      final result = await service.regalaPunti(
        daTelefono: '111',
        aTelefono: '222',
        punti: 30,
        messaggio: 'Test regalo',
      );

      expect(result['success'], true);

      // Verify punti updated
      final mittenteSnap = await firestore.collection('clienti').doc('c1').get();
      final destinatarioSnap = await firestore.collection('clienti').doc('c2').get();

      expect(mittenteSnap.data()!['punti'], 70);
      expect(destinatarioSnap.data()!['punti'], 40);

      // Verify regaliPunti doc created
      final regali = await firestore.collection('regaliPunti').get();
      expect(regali.docs.length, 1);
      final doc = regali.docs.first.data();
      expect(doc['daTelefono'], '111');
      expect(doc['aTelefono'], '222');
      expect(doc['punti'], 30);

      // verify streams produce the doc
      final sent = await service.getRegaliInviati('111').first;
      expect(sent.length, 1);
      expect(sent.first['aTelefono'], '222');

      final received = await service.getRegaliRicevuti('222').first;
      expect(received.length, 1);
      expect(received.first['daTelefono'], '111');
    });
  });
}
