import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

/// Minimal email sender used by the app (wraps a Resend API call).
/// Restored and simplified to a single well-formed implementation.
class EmailService {
  // Replace with your real Resend API key. Keep it secret.
  static const String _resendApiKey = 're_2axa3mBv_F9d58zATjtUiL7kE7pw8dht3';
  static const String _resendApiUrl = 'https://api.resend.com/emails';

  static Future<bool> sendPasswordRecuperoPassword({
    required String toEmail,
    required String customerName,
    required String password,
  }) async {
    try {
      dev.log('🚀 Tentativo invio email con Resend a: $toEmail', name: 'EmailService');

      if (_resendApiKey.startsWith('re_xxx')) {
        dev.log('❌ ATTENZIONE: API Key non configurata!', name: 'EmailService');
        return false;
      }

      final response = await http.post(
        Uri.parse(_resendApiUrl),
        headers: {
          'Authorization': 'Bearer $_resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'noreply@yourdomain.com',
          'to': [toEmail],
          'subject': '🔐 La tua Password - Ristorante App',
          'html': '<p>Ciao $customerName, la tua password temporanea: <strong>$password</strong></p>'
        }),
      );

      dev.log('📧 Response status: ${response.statusCode}', name: 'EmailService');
      dev.log('📧 Response body: ${response.body}', name: 'EmailService');

      return response.statusCode == 200;
    } catch (e) {
      dev.log('❌ Eccezione durante invio email: $e', name: 'EmailService');
      return false;
    }
  }

  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String customerName,
    required String password,
  }) async {
    try {
      if (_resendApiKey.startsWith('re_xxx')) return false;
      final response = await http.post(
        Uri.parse(_resendApiUrl),
        headers: {
          'Authorization': 'Bearer $_resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'noreply@yourdomain.com',
          'to': [toEmail],
          'subject': '🎉 Benvenuto nel Sistema Fedeltà!',
          'html': '<p>Benvenuto $customerName! La password temporanea: <strong>$password</strong></p>'
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> sendPasswordResetTokenEmail({
    required String toEmail,
    required String customerName,
    required String resetToken,
    required String appBaseUrl,
  }) async {
    try {
      if (_resendApiKey.startsWith('re_xxx')) return false;
      final resetUrl = '$appBaseUrl?token=$resetToken';
      final response = await http.post(
        Uri.parse(_resendApiUrl),
        headers: {
          'Authorization': 'Bearer $_resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'noreply@yourdomain.com',
          'to': [toEmail],
          'subject': '🔐 Reset Password - Ristorante App',
          'html': '<p>Clicca qui per resettare la password: <a href="$resetUrl">Reset</a></p>'
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
