import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 helper utilities
class PasswordUtils {
  /// Generate a random salt of given length
  static List<int> generateSalt([int length = 16]) {
    final rnd = DateTime.now().microsecondsSinceEpoch;
    final seed = utf8.encode(rnd.toString());
    final h = sha256.convert(seed).bytes;
    return h.sublist(0, length);
  }

  static List<int> _int32be(int i) {
    final b = ByteData(4);
    b.setUint32(0, i, Endian.big);
    return b.buffer.asUint8List();
  }

  static List<int> _hmac(Uint8List key, List<int> data) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(data).bytes;
  }

  static List<int> pbkdf2(String password, List<int> salt, int iterations, int dkLen) {
    final key = utf8.encode(password);
    final Uint8List keyBytes = Uint8List.fromList(key);
    final int hashLen = sha256.convert([]).bytes.length;
    final int blocks = (dkLen + hashLen - 1) ~/ hashLen;
    final List<int> dk = [];

    for (int block = 1; block <= blocks; block++) {
  final List<int> initial = [...salt, ..._int32be(block)];
      List<int> u = _hmac(keyBytes, initial);
      List<int> t = List<int>.from(u);
      for (int i = 1; i < iterations; i++) {
        u = _hmac(keyBytes, u as Uint8List);
        for (int j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      dk.addAll(t);
    }

    return dk.sublist(0, dkLen);
  }

  /// Hash password -> returns map with base64 encoded derivedKey, salt and iterations
  static Map<String, dynamic> hashPassword(String password, {int iterations = 100000, int dkLen = 32}) {
    final salt = generateSalt(16);
    final derived = pbkdf2(password, salt, iterations, dkLen);
    return {
      'password_hash': base64Url.encode(derived),
      'password_salt': base64Url.encode(salt),
      'password_iterations': iterations,
      'dk_len': dkLen,
    };
  }

  static bool verifyPassword(String password, String storedHashB64, String saltB64, int iterations, int dkLen) {
    final salt = base64Url.decode(saltB64);
    final derived = pbkdf2(password, salt, iterations, dkLen);
    final derivedB64 = base64Url.encode(derived);
    return _constantTimeEquals(derivedB64, storedHashB64);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var res = 0;
    for (var i = 0; i < a.length; i++) {
      res |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return res == 0;
  }
}
