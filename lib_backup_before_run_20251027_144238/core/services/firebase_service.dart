/// FILE: [lib/core/services/firebase_service.dart]
/// SCOPO: [Factory centrale per tutti i servizi Firebase]
/// MODIFICHE: [Aggiunto OrdiniService al factory]
library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as fb_core;
import 'client_auth_service.dart';
import 'menu_services/menu_service.dart';
import '../../services/email_service.dart';
// Use the bridge ArchiveService and PointsService from the main package so
// lib_new UI delegates to the legacy-tested implementations.
import 'package:ordinazione/core/services/archive_service.dart';
import 'package:ordinazione/core/services/point_service.dart';
import 'ordini_service.dart'; // ✅ AGGIUNTO

class FirebaseService {
  // Lazily-created singleton to avoid accessing Firebase (and native
  // plugins) during Dart static initialization. This prevents accidental
  // calls to `FirebaseFirestore.instance` before `Firebase.initializeApp()`
  // has been awaited by the entrypoint.
  static FirebaseService? _instance;
  factory FirebaseService() => _instance ??= FirebaseService._internal();
  FirebaseService._internal();

  FirebaseFirestore? _firestore;

  FirebaseFirestore get _firestoreInstance {
    // Provide a clearer error if Firebase wasn't initialized yet.
    if (fb_core.Firebase.apps.isEmpty) {
      throw StateError('Firebase has not been initialized. Call Firebase.initializeApp() before using FirebaseService.');
    }
    return _firestore ??= FirebaseFirestore.instance;
  }

  ClientAuthService get _clientAuth => ClientAuthService(_firestoreInstance);
  // Bridge-backed services
  ArchiveService get _archive => ArchiveService(_firestoreInstance);
  PointsService get _points => PointsService(_firestoreInstance);
  OrdiniService get _ordini => OrdiniService(_firestoreInstance); // ✅ NUOVO SERVICE
  
  FirebaseFirestore get firestore => _firestoreInstance;

  // Static convenience accessors to preserve older static usage in UI code
  // Static convenience accessors to preserve older static usage in UI code
  static ClientAuthService get clientAuth => FirebaseService()._clientAuth;
  static ArchiveService get archive => FirebaseService()._archive;
  static PointsService get points => FirebaseService()._points;
  static OrdiniService get ordini => FirebaseService()._ordini;
  static MenuService get menu => MenuService();

  // Email service bridge (legacy EmailService lives in services/email_service.dart)
  static const email = _EmailBridge();
}

// Thin bridge to call the legacy EmailService static methods without changing many call sites
class _EmailBridge {
  const _EmailBridge();

  Future<bool> sendPasswordResetTokenEmail({required String toEmail, required String customerName, required String resetToken, required String appBaseUrl}) {
    return EmailService.sendPasswordResetTokenEmail(toEmail: toEmail, customerName: customerName, resetToken: resetToken, appBaseUrl: appBaseUrl);
  }
}