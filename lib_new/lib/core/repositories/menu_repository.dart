import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordinazione/core/services/firebase_service.dart' as core_fb;
import 'package:ordinazione/models/macrocategoria_model.dart';
import 'package:ordinazione/models/categoria_model.dart';
import 'package:ordinazione/models/pietanza_model.dart';

class MenuRepository {
  // Defer obtaining the Firestore instance until first use to avoid
  // initialization-order issues when the app entrypoint initializes Firebase.
  FirebaseFirestore get _firestore => core_fb.FirebaseService().firestore;

  // Riferimenti alle collezioni
  CollectionReference get _macrocategorieCollection => 
      _firestore.collection('ristoranti').doc('mille_vetrine').collection('macrocategorie');
  
  CollectionReference get _categorieCollection => 
      _firestore.collection('ristoranti').doc('mille_vetrine').collection('categorie');
  
  CollectionReference get _pietanzeCollection => 
      _firestore.collection('ristoranti').doc('mille_vetrine').collection('pietanze');

  // ========== MACROCATEGORIE ==========
  Stream<List<Macrocategoria>> getMacrocategorieStream() {
    return _macrocategorieCollection
        .orderBy('ordine')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Macrocategoria.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  Future<void> aggiungiMacrocategoria(Macrocategoria macrocategoria) async {
    await _macrocategorieCollection
        .doc(macrocategoria.id)
        .set(macrocategoria.toMap());
  }

  Future<void> modificaMacrocategoria(String id, Macrocategoria macrocategoria) async {
    await _macrocategorieCollection
        .doc(id)
        .update(macrocategoria.toMap());
  }

  Future<void> eliminaMacrocategoria(String id) async {
    await _macrocategorieCollection.doc(id).delete();
  }

  Future<void> riordinaMacrocategorie(List<Macrocategoria> macrocategorie) async {
    final batch = _firestore.batch();
    
    for (int i = 0; i < macrocategorie.length; i++) {
      final docRef = _macrocategorieCollection.doc(macrocategorie[i].id);
      batch.update(docRef, {'ordine': i});
    }
    
    await batch.commit();
  }

  // ========== CATEGORIE ==========
  Stream<List<Categoria>> getCategorieStream() {
    return _categorieCollection
        .orderBy('ordine')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Categoria.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  Future<void> aggiungiCategoria(Categoria categoria) async {
    await _categorieCollection
        .doc(categoria.id)
        .set(categoria.toMap());
  }

  Future<void> modificaCategoria(String id, Categoria categoria) async {
    await _categorieCollection
        .doc(id)
        .update(categoria.toMap());
  }

  Future<void> eliminaCategoria(String id) async {
    await _categorieCollection.doc(id).delete();
  }

  Future<void> riordinaCategorie(List<Categoria> categorie) async {
    final batch = _firestore.batch();
    
    for (int i = 0; i < categorie.length; i++) {
      final docRef = _categorieCollection.doc(categorie[i].id);
      batch.update(docRef, {'ordine': i});
    }
    
    await batch.commit();
  }

  // ========== PIETANZE ==========
  Stream<List<Pietanza>> getPietanzeStream() {
    return _pietanzeCollection
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pietanza.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  Future<void> aggiungiPietanza(Pietanza pietanza) async {
    await _pietanzeCollection
        .doc(pietanza.id)
        .set(pietanza.toMap());
  }

  Future<void> modificaPietanza(String id, Pietanza pietanza) async {
    await _pietanzeCollection
        .doc(id)
        .update(pietanza.toMap());
  }

  Future<void> eliminaPietanza(String id) async {
    await _pietanzeCollection.doc(id).delete();
  }

  Future<void> aggiornaDisponibilitaPietanza(String id, bool disponibile) async {
    await _pietanzeCollection
        .doc(id)
        .update({'disponibile': disponibile});
  }

  // ========== METODI DI SUPPORTO ==========
  Stream<List<Categoria>> getCategorieByMacrocategoriaStream(String macrocategoriaId) {
    return _categorieCollection
        .where('macrocategoriaId', isEqualTo: macrocategoriaId)
        .orderBy('ordine')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Categoria.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  Stream<List<Pietanza>> getPietanzeByCategoriaStream(String categoriaId) {
    return _pietanzeCollection
        .where('categoriaId', isEqualTo: categoriaId)
        .where('disponibile', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pietanza.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  Stream<List<Pietanza>> getPietanzeByMacrocategoriaStream(String macrocategoriaId) {
    return _pietanzeCollection
        .where('macrocategoriaId', isEqualTo: macrocategoriaId)
        .where('categoriaId', isNull: true) // Solo pietanze senza categoria
        .where('disponibile', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pietanza.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  // Caricamento dati iniziali (solo se necessario)
  Future<void> caricaDatiIniziali() async {
    // Verifica se esistono già dati
    final macrocategorieSnapshot = await _macrocategorieCollection.get();
    if (macrocategorieSnapshot.docs.isNotEmpty) {
      return; // I dati esistono già
    }

    // Carica dati demo
    final macrocategorieDemo = [
      Macrocategoria(id: '1', nome: 'Antipasti', emoji: '🥗', ordine: 0),
      Macrocategoria(id: '2', nome: 'Primi', emoji: '🍝', ordine: 1),
      Macrocategoria(id: '3', nome: 'Secondi', emoji: '🍖', ordine: 2),
      Macrocategoria(id: '4', nome: 'Dolci', emoji: '🍰', ordine: 3),
      Macrocategoria(id: '5', nome: 'Bevande', emoji: '🍷', ordine: 4),
    ];

    for (final macrocategoria in macrocategorieDemo) {
      await aggiungiMacrocategoria(macrocategoria);
    }
  }
}