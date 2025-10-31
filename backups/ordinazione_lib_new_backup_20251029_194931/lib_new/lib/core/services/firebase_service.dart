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
// MenuService used by legacy UI code expecting FirebaseService.menu
import 'menu_services/menu_service.dart';

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

  ClientAuthService get clientAuth => ClientAuthService(_firestoreInstance);
  // Bridge-backed services
  ArchiveService get archive => ArchiveService(_firestoreInstance);
  PointsService get points => PointsService(_firestoreInstance);
  OrdiniService get ordini => OrdiniService(_firestoreInstance); // ✅ NUOVO SERVICE
  // Provide a static MenuService accessor for legacy code
  static final MenuService menu = MenuService();

  FirebaseFirestore get firestore => _firestoreInstance;
}