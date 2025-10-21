import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

class EmailService {
  // 👇 SOSTITUISCI CON LA TUA API KEY DI RESEND
  static const String _resendApiKey = 're_2axa3mBv_F9d58zATjtUiL7kE7pw8dht3';
  static const String _resendApiUrl = 'https://api.resend.com/emails';

  // 👇 INVIO EMAIL DI RECUPERO PASSWORD CON RESEND
  static Future<bool> sendPasswordRecuperoPassword({
    required String toEmail,
    required String customerName,
    required String password,
  }) async {
    try {
      dev.log('🚀 Tentativo invio email con Resend a: $toEmail', name: 'EmailService');
      
      // Verifica che l'API key sia stata sostituita
      if (_resendApiKey.startsWith('re_xxx')) {
        dev.log('❌ ATTENZIONE: API Key non configurata! Inserisci la tua API Key da Resend.com', name: 'EmailService');
        return false;
      }
      
      final response = await http.post(
        Uri.parse(_resendApiUrl),
        headers: {
          'Authorization': 'Bearer $_resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'noreply@millevetrine.com', // 👈 USEREMO IL TUO DOMINIO
          'to': [toEmail],
          'subject': '🔐 La tua Password - Ristorante App',
          'html': '''
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <style>
                    body { 
                        font-family: 'Arial', sans-serif; 
                        background-color: #f4f4f4; 
                        margin: 0; 
                        padding: 20px; 
                    }
                    .container { 
                        max-width: 600px; 
                        margin: 0 auto; 
                        background: white; 
                        padding: 30px; 
                        border-radius: 10px; 
                        box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
                    }
                    .header { 
                        text-align: center; 
                        background: linear-gradient(135deg, #FF6B8B, #FF8FA3); 
                        padding: 20px; 
                        border-radius: 10px 10px 0 0; 
                        color: white; 
                    }
                    .password-box { 
                        background: #fff3cd; 
                        border: 2px solid #ffc107; 
                        padding: 15px; 
                        border-radius: 8px; 
                        text-align: center; 
                        margin: 20px 0; 
                        font-size: 18px; 
                        font-weight: bold; 
                    }
                    .footer { 
                        text-align: center; 
                        margin-top: 20px; 
                        color: #666; 
                        font-size: 12px; 
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🔐 Recupero Password</h1>
                        <p>Ristorante App - Sistema Fedeltà</p>
                    </div>
                    
                    <h2>Ciao $customerName!</h2>
                    <p>Hai richiesto il recupero della tua password. Ecco i tuoi dati di accesso:</p>
                    
                    <div class="password-box">
                        <strong>La tua password:</strong><br>
                        <span style="color: #d63384; font-size: 20px;">$password</span>
                    </div>
                    
                    <p><strong>Come accedere:</strong></p>
                    <ol>
                        <li>Apri l'App del Ristorante</li>
                        <li>Clicca su "Profilo Cliente"</li>
                        <li>Inserisci il tuo telefono e questa password</li>
                        <li>Clicca "ACCEDI"</li>
                    </ol>
                    
                    <p><strong>💡 Consiglio di sicurezza:</strong></p>
                    <ul>
                        <li>Non condividere questa password con nessuno</li>
                        <li>Cambia la password dopo il primo accesso</li>
                        <li>Se non hai richiesto tu questo recupero, ignora questa email</li>
                    </ul>
                    
                    <div class="footer">
                        <p>⚡ Email inviata tramite Resend.com</p>
                        <p>© 2024 Ristorante App - Tutti i diritti riservati</p>
                    </div>
                </div>
            </body>
            </html>
          ''',
        }),
      );

  dev.log('📧 Response status: ${response.statusCode}', name: 'EmailService');
  dev.log('📧 Response body: ${response.body}', name: 'EmailService');

      if (response.statusCode == 200) {
        dev.log('✅ Email inviata con successo a: $toEmail', name: 'EmailService');
        return true;
      } else {
        dev.log('❌ Errore Resend: ${response.statusCode} - ${response.body}', name: 'EmailService');
        return false;
      }
    } catch (e) {
      dev.log('❌ Eccezione durante invio email: $e', name: 'EmailService');
      return false;
    }
  }

  // 👇 INVIO EMAIL DI BENVENUTO PER NUOVA REGISTRAZIONE
  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String customerName,
    required String password,
  }) async {
    try {
      // Verifica che l'API key sia stata sostituita
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
          'from': 'noreply@millevetrine.com', // 👈 USEREMO IL TUO DOMINIO
          'to': [toEmail],
          'subject': '🎉 Benvenuto nel Sistema Fedeltà!',
          'html': '''
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <style>
                    body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; }
                    .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }
                    .header { text-align: center; background: linear-gradient(135deg, #4CAF50, #45a049); padding: 20px; border-radius: 10px; color: white; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🎉 Benvenuto $customerName!</h1>
                    </div>
                    <p>Il tuo account è stato creato con successo!</p>
                    <p><strong>Password temporanea:</strong> $password</p>
                    <p>Accedi all'app con il tuo telefono e questa password per accumulare punti!</p>
                </div>
            </body>
            </html>
          ''',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      dev.log('❌ Errore invio email benvenuto: $e', name: 'EmailService');
      return false;
    }
  }
}