// Use the well-maintained fake_cloud_firestore package for tests.
// This file re-exports the FakeFirebaseFirestore implementation so existing
// tests that import this local file keep working without needing to change
// imports site-wide.
export 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
