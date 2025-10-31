import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final projectId = Platform.environment['FB_PROJECT_ID'] ?? 'demo-no-project';
  final firestoreHost = Platform.environment['FIRESTORE_EMULATOR_HOST'] ?? '127.0.0.1:8080';
  final baseUrl = Uri.parse('http://$firestoreHost/v1/projects/$projectId/databases/(default)/documents/sessions');

  print('Running Dart CLI emulator test against $baseUrl');

  try {
    // create without token -> expect 403
    final noAuthResp = await _post(baseUrl, _makeBody());
    if (noAuthResp.statusCode != 403) {
      stderr.writeln('Expected 403 for unauthenticated create, got: ${noAuthResp.statusCode}');
      exit(1);
    }

    // load token
    final tokenFile = File('token.json');
    final toolingTokenFile = File('tooling/token.json');
    File tokenSource = toolingTokenFile.existsSync() ? toolingTokenFile : tokenFile;
    if (!tokenSource.existsSync()) {
      stderr.writeln('token.json not found at tooling/token.json or token.json. Run tooling/gen-token to create it.');
      exit(1);
    }
    final tokenJson = jsonDecode(await tokenSource.readAsString()) as Map<String, dynamic>;
    final idToken = tokenJson['idToken'] as String?;
    if (idToken == null) {
      stderr.writeln('idToken not found inside token.json');
      exit(1);
    }

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $idToken'};

    // create
    final createResp = await _post(baseUrl, _makeBody(), headers: headers);
    if (createResp.statusCode != 200) {
      stderr.writeln('Expected 200 on create with staff token, got ${createResp.statusCode}: ${await _readResponseBody(createResp)}');
      exit(1);
    }
    final created = jsonDecode(await _readResponseBody(createResp)) as Map<String, dynamic>;
    final name = created['name'] as String?;
    if (name == null || !name.contains('/sessions/')) {
      stderr.writeln('Created response missing name: $created');
      exit(1);
    }
    final docId = name.split('/').last;

    // read
    final readResp = await _get(Uri.parse('${baseUrl.toString()}/$docId'), headers: headers);
    if (readResp.statusCode != 200) {
      stderr.writeln('Expected 200 on read, got ${readResp.statusCode}: ${await _readResponseBody(readResp)}');
      exit(1);
    }

    // patch
    final patchUrl = Uri.parse('${baseUrl.toString()}/$docId?updateMask.fieldPaths=attiva&updateMask.fieldPaths=expiresAt');
    final patchBody = {
      'fields': {
        'attiva': {'booleanValue': false},
        'expiresAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()}
      }
    };
    final patchResp = await _patch(patchUrl, patchBody, headers: headers);
    if (patchResp.statusCode != 200) {
      stderr.writeln('Expected 200 on patch, got ${patchResp.statusCode}: ${await _readResponseBody(patchResp)}');
      exit(1);
    }

    // read after patch -> expected 403
    final read2 = await _get(Uri.parse('${baseUrl.toString()}/$docId'), headers: headers);
    if (read2.statusCode != 403) {
      stderr.writeln('Expected 403 after patch (attiva=false), got ${read2.statusCode}: ${await _readResponseBody(read2)}');
      exit(1);
    }

    print('Dart CLI emulator test passed');
    exit(0);
  } catch (e, st) {
    stderr.writeln('Test failed: $e');
    stderr.writeln(st);
    exit(1);
  }
}

Map<String, dynamic> _makeBody() {
  return {
    'fields': {
      'codice': {'stringValue': 'S-DART-CLI-TEST'},
      'numeroTavolo': {'integerValue': '99'},
      'idCameriere': {'stringValue': 'dart-staff'},
      'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      'expiresAt': {'timestampValue': DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String()},
      'attiva': {'booleanValue': true}
    }
  };
}

Future<String> _readResponseBody(HttpClientResponse resp) async {
  final body = await utf8.decoder.bind(resp).join();
  return body;
}

Future<HttpClientResponse> _post(Uri url, Map body, {Map<String, String>? headers}) async {
  final client = HttpClient();
  final req = await client.postUrl(url);
  headers?.forEach((k, v) => req.headers.set(k, v));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode(body));
  return await req.close();
}

Future<HttpClientResponse> _get(Uri url, {Map<String, String>? headers}) async {
  final client = HttpClient();
  final req = await client.getUrl(url);
  headers?.forEach((k, v) => req.headers.set(k, v));
  return await req.close();
}

Future<HttpClientResponse> _patch(Uri url, Map body, {Map<String, String>? headers}) async {
  final client = HttpClient();
  final req = await client.openUrl('PATCH', url);
  headers?.forEach((k, v) => req.headers.set(k, v));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode(body));
  return await req.close();
}
