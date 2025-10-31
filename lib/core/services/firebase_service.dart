/// FILE: [lib/core/services/firebase_service.dart]
/// SCOPO: [Factory centrale per tutti i servizi Firebase]
/// MODIFICHE: [Aggiunto OrdiniService al factory]
library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as fb_core;
import 'client_auth_service.dart';
// Use the bridge ArchiveService and PointsService from the main package so
// lib_new UI delegates to the legacy-tested implementations.
import 'package:ordinazione/core/services/archive_service.dart';
import 'package:ordinazione/core/services/point_service.dart';
import 'ordini_service.dart'; // ✅ AGGIUNTO
import 'package:ordinazione/services/email_service.dart';

class FirebaseService {
  static FirebaseService? _instance;
  factory FirebaseService() => _instance ??= FirebaseService._internal();
  FirebaseService._internal();

  FirebaseFirestore? _firestore;

  FirebaseFirestore get _firestoreInstance {
    if (fb_core.Firebase.apps.isEmpty) {
      throw StateError('Firebase has not been initialized. Call Firebase.initializeApp() before using FirebaseService.');
    }
    return _firestore ??= FirebaseFirestore.instance;
  }

  // Instance-backed services (cached per FirebaseService singleton)
  late final ClientAuthService _clientAuth = ClientAuthService(_firestoreInstance);
  late final ArchiveService _archive = ArchiveService(_firestoreInstance);
  late final PointsService _points = PointsService(_firestoreInstance);
  late final OrdiniService _ordini = OrdiniService(_firestoreInstance); // ✅ NUOVO SERVICE

  FirebaseFirestore get firestore => _firestoreInstance;

  // Instance getters to support code that uses FirebaseService().<service>
  // Backwards-compatible instance getters (so callers can use FirebaseService().clientAuth etc.)
  ClientAuthService get clientAuth => _clientAuth;
  PointsService get points => _points;
  ArchiveService get archive => _archive;
  OrdiniService get ordini => _ordini;
  static final _EmailFacade _emailFacade = _EmailFacade();
  // Return as dynamic to avoid exposing a private type in a public API while
  // keeping call sites working (they expect sendPasswordResetTokenEmail/sendWelcomeEmail etc.).
  static dynamic get email => _emailFacade;
}

class _EmailFacade {
  Future<bool> sendPasswordResetTokenEmail({required String toEmail, required String customerName, required String resetToken, required String appBaseUrl}) {
    return EmailService.sendPasswordResetTokenEmail(toEmail: toEmail, customerName: customerName, resetToken: resetToken, appBaseUrl: appBaseUrl);
  }

  Future<bool> sendWelcomeEmail({required String toEmail, required String customerName, required String password}) {
    return EmailService.sendWelcomeEmail(toEmail: toEmail, customerName: customerName, password: password);
  }

  Future<bool> sendPasswordRecuperoPassword({required String toEmail, required String customerName, required String password}) {
    return EmailService.sendPasswordRecuperoPassword(toEmail: toEmail, customerName: customerName, password: password);
  }
}

// End of firebase_service