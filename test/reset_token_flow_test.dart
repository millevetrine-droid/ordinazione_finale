import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ordinazione/services/firebase/client_auth_service.dart' as new_auth;
import 'package:ordinazione/core/utils/password_utils.dart';

void main() {
  test('reset token lifecycle', () async {
    final fakeFs = FakeFirebaseFirestore();
    final service = new_auth.ClientAuthService(fakeFs);

    // create a fake client
    const telefono = '3334445555';
    await fakeFs.collection('clienti').doc(telefono).set({
      'telefono': telefono,
      'nome': 'Test User',
      'punti': 0,
    });

    final token = await service.generateResetToken(telefono, ttl: const Duration(minutes: 10));
    expect(token, isNotNull);

    final valid = await service.verifyResetToken(telefono, token);
    expect(valid, isTrue);

    const newPass = 'new-secret-pass';
    final ok = await service.setNewPassword(telefono, newPass);
    expect(ok, isTrue);

    // verify stored hash
    final doc = await fakeFs.collection('clienti').doc(telefono).get();
    final data = doc.data()!;
    expect(data.containsKey('password_hash'), isTrue);
    expect(data.containsKey('password_salt'), isTrue);

    // verify password using PasswordUtils
    final storedHash = data['password_hash'] as String;
    final salt = data['password_salt'] as String;
    final iter = data['password_iterations'] as int;
    final dkLen = data['dk_len'] as int;

    final okVerify = PasswordUtils.verifyPassword(newPass, storedHash, salt, iter, dkLen);
    expect(okVerify, isTrue);
  });
}
