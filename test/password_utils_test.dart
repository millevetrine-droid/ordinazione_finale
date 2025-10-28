import 'package:flutter_test/flutter_test.dart';
import 'package:ordinazione/core/utils/password_utils.dart';

void main() {
  test('hash and verify password using PBKDF2', () {
  const password = 'My\$ecretP@ssw0rd';
    final result = PasswordUtils.hashPassword(password, iterations: 1000, dkLen: 32);

    expect(result.containsKey('password_hash'), isTrue);
    expect(result.containsKey('password_salt'), isTrue);
    expect(result.containsKey('password_iterations'), isTrue);

    final hash = result['password_hash'] as String;
    final salt = result['password_salt'] as String;
    final iter = result['password_iterations'] as int;
    final dkLen = result['dk_len'] as int;

    final ok = PasswordUtils.verifyPassword(password, hash, salt, iter, dkLen);
    expect(ok, isTrue);

    final bad = PasswordUtils.verifyPassword('wrongpass', hash, salt, iter, dkLen);
    expect(bad, isFalse);
  });
}
