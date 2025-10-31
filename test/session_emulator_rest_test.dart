import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  const projectId = String.fromEnvironment('FB_PROJECT_ID', defaultValue: 'demo-no-project');
  const firestoreHost = String.fromEnvironment('FIRESTORE_EMULATOR_HOST', defaultValue: '127.0.0.1:8080');

  final baseUrl = 'http://$firestoreHost/v1/projects/$projectId/databases/(default)/documents/sessions';

  group('Session emulator REST tests', () {
    test('create without token should be forbidden', () async {
      final body = _makeBody();
      final resp = await http.post(Uri.parse(baseUrl), body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
      expect(resp.statusCode, 403);
    });

    test('create with staff token -> create, patch, and final read forbidden', () async {
      // token.json should be created by running `cd tooling && npm run gen-token`
      final tokenFile = File('tooling/token.json');
      expect(await tokenFile.exists(), isTrue, reason: 'Run `cd tooling && npm run gen-token` first to create tooling/token.json');
      final tokenJson = jsonDecode(await tokenFile.readAsString());
      final idToken = tokenJson['idToken'] as String;
      expect(idToken, isNotNull);

      final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $idToken'};

      // create
      final createResp = await http.post(Uri.parse(baseUrl), body: jsonEncode(_makeBody()), headers: headers);
      expect(createResp.statusCode, 200);
      final created = jsonDecode(createResp.body) as Map<String, dynamic>;
      final name = created['name'] as String;
      expect(name, contains('/sessions/'));
      final docId = name.split('/').last;

      // read
      final readResp = await http.get(Uri.parse('$baseUrl/$docId'), headers: headers);
      expect(readResp.statusCode, 200);

      // patch (end session)
      final patchUrl = Uri.parse('$baseUrl/$docId?updateMask.fieldPaths=attiva&updateMask.fieldPaths=expiresAt');
      final patchBody = {
        'fields': {
          'attiva': {'booleanValue': false},
          'expiresAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()}
        }
      };
      final patchResp = await http.patch(patchUrl, body: jsonEncode(patchBody), headers: headers);
      expect(patchResp.statusCode, 200);

      // read after patch -> expected 403 because attiva=false
      final read2 = await http.get(Uri.parse('$baseUrl/$docId'), headers: headers);
      expect(read2.statusCode, 403);
    });
  });
}

Map<String, dynamic> _makeBody() {
  return {
    'fields': {
      'codice': {'stringValue': 'S-DART-TEST'},
      'numeroTavolo': {'integerValue': '99'},
      'idCameriere': {'stringValue': 'dart-staff'},
      'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      'expiresAt': {'timestampValue': DateTime.now().add(Duration(hours: 1)).toUtc().toIso8601String()},
      'attiva': {'booleanValue': true}
    }
  };
}
