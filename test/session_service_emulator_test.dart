// Test per SessionService usando Firestore Emulator.
// Requisiti: l'emulatore deve essere avviato (localhost:8080) e firebase emulators:start

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordinazione/core/services/session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // In ambiente di test locale, chiama initializeApp e connetti all'emulatore
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
  });

  test('create -> join -> end session flow', () async {
    final service = SessionService();

    // Crea sessione
    final sessionId = await service.createSession(numeroTavolo: 42, idCameriere: 'test-staff', ttl: const Duration(minutes: 10));
    expect(sessionId, isNotNull);

    // Recupera la sessione e il codice
    final s1 = await service.getSessionById(sessionId);
    expect(s1, isNotNull);
    final codice = s1!.codice;
    expect(codice, isNotEmpty);

    // Join by codice
    final joined = await service.joinSessionByCode(codice);
    expect(joined, isNotNull);
    expect(joined!.numeroTavolo, equals(42));

    // Termina sessione
    await service.endSession(sessionId);

    // Dopo end, join deve fallire
    final joined2 = await service.joinSessionByCode(codice);
    expect(joined2, isNull);
  });
}
