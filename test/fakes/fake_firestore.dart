import 'package:cloud_firestore/cloud_firestore.dart';

// Minimal fake classes to simulate the API used by MenuRepositoryFirestore.
// This is intentionally small and only implements the pieces we need.

class FakeDocumentSnapshot implements DocumentSnapshot {
  final String id;
  final Map<String, dynamic> dataMap;

  FakeDocumentSnapshot(this.id, this.dataMap);

  @override
  Map<String, dynamic> data() => dataMap;

  // The rest of the API isn't needed for our tests; throw if used.
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeQuerySnapshot implements QuerySnapshot {
  final List<FakeDocumentSnapshot> docsList;

  FakeQuerySnapshot(this.docsList);

  @override
  List<DocumentSnapshot> get docs => docsList;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCollectionReference implements CollectionReference {
  final List<FakeDocumentSnapshot> _docs;

  FakeCollectionReference(this._docs);

  @override
  Future<QuerySnapshot> get([GetOptions? options]) async {
    return FakeQuerySnapshot(_docs);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirebaseFirestore implements FirebaseFirestore {
  final Map<String, FakeCollectionReference> _collections;

  FakeFirebaseFirestore(this._collections);

  @override
  CollectionReference collection(String path) {
    return _collections[path] ?? FakeCollectionReference([]);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
