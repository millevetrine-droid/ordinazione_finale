/// FILE: [lib/core/services/firebase_service.dart]
/// SCOPO: [Factory centrale per tutti i servizi Firebase]
/// MODIFICHE: [Aggiunto OrdiniService al factory]
library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'client_auth_service.dart';
// Use the bridge ArchiveService and PointsService from the main package so
// lib_new UI delegates to the legacy-tested implementations.
import 'package:ordinazione/core/services/archive_service.dart';
import 'package:ordinazione/core/services/point_service.dart';
import 'ordini_service.dart'; // ✅ AGGIUNTO

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClientAuthService get clientAuth => ClientAuthService(_firestore);
  // Bridge-backed services
  ArchiveService get archive => ArchiveService(_firestore);
  PointsService get points => PointsService(_firestore);
  OrdiniService get ordini => OrdiniService(_firestore); // ✅ NUOVO SERVICE
  
  FirebaseFirestore get firestore => _firestore;
}