import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordinazione/core/services/firebase_service.dart' as core_fb;
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:ordinazione/models/pietanza_model.dart';
import 'package:ordinazione/models/categoria_model.dart';
import 'package:ordinazione/utils/color_utils.dart';

class MenuFirestoreService {
  // Use a getter so we don't access `FirebaseFirestore.instance` at
  // module/class construction time (which can happen before
  // `Firebase.initializeApp()`); resolving at call-time is safe.
  FirebaseFirestore get _firestore => core_fb.FirebaseService().firestore;

  Future<Map<String, dynamic>> caricaTuttiIDati() async {
    final results = await Future.wait([
      _caricaPietanze(),
      _caricaCategorie(),
      _caricaOfferte(),
    ], eagerError: true);

    return {
      'pietanze': results[0],
      'categorie': results[1],
      'offerte': results[2],
    };
  }

  Future<List<Pietanza>> _caricaPietanze() async {
    try {
      final snapshot = await _firestore
          .collection('pietanze')
          .where('disponibile', isEqualTo: true)
          .get(const GetOptions(source: Source.serverAndCache));

      final list = snapshot.docs.map((doc) => Pietanza.fromMap(doc.data())).toList();
      list.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return list;
    } catch (e) {
      dev.log('⚠️ Errore caricamento pietanze: $e', name: 'MenuFirestoreService');
      return [];
    }
  }

  Future<List<Categoria>> _caricaCategorie() async {
    try {
      final snapshot = await _firestore
          .collection('categorie')
          .orderBy('ordine')
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs.map((doc) => Categoria.fromMap(doc.data())).toList();
    } catch (e) {
      dev.log('⚠️ Errore caricamento categorie: $e', name: 'MenuFirestoreService');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _caricaOfferte() async {
    try {
      final snapshot = await _firestore
          .collection('offerte')
          .where('attiva', isEqualTo: true)
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'titolo': data['titolo'] ?? '',
          'sottotitolo': data['sottotitolo'] ?? '',
          'prezzo': (data['prezzo'] as num?)?.toDouble() ?? 0.0,
          'immagine': data['immagine'] ?? '🍕',
          'colore': ColorParser.parseColor(data['colore']),
          'linkTipo': data['linkTipo'] ?? 'categoria',
          'linkDestinazione': data['linkDestinazione'] ?? '',
          'attiva': data['attiva'] ?? true,
          'ordine': data['ordine'] ?? 0,
        };
      }).where((offerta) => offerta['attiva'] == true).toList();
    } catch (e) {
      dev.log('⚠️ Errore caricamento offerte: $e', name: 'MenuFirestoreService');
      return [];
    }
  }

  Future<void> salvaCategoria(Categoria categoria) async {
    await _firestore.collection('categorie').doc(categoria.id).set(categoria.toMap());
  }

  Future<void> salvaPietanza(Pietanza pietanza) async {
    await _firestore.collection('pietanze').doc(pietanza.id).set(pietanza.toMap());
  }

  Future<void> salvaOfferta(Map<String, dynamic> offerta) async {
    final offertaData = Map<String, dynamic>.from(offerta);
    if (offertaData['colore'] is Color) {
      offertaData['colore'] = ColorParser.colorToHex(offertaData['colore'] as Color);
    }
    await _firestore.collection('offerte').doc(offerta['id']).set(offertaData);
  }

  Future<void> eliminaCategoria(
    String categoriaId,
    List<Categoria> categorieMenu,
    List<Pietanza> pietanzeMenu,
  ) async {
    final pietanzeInCategoria = pietanzeMenu.where((p) => p.categoriaId == categoriaId).toList();
    if (pietanzeInCategoria.isNotEmpty) {
      throw 'Non puoi eliminare una categoria che contiene pietanze. Sposta prima le pietanze in un\'altra categoria.';
    }

    final categoria = categorieMenu.firstWhere((c) => c.id == categoriaId);
    if (categoria.tipo == 'macrocategoria') {
      final sottocategorie = categorieMenu.where((c) => c.tipo == 'sottocategoria' && c.idPadre == categoriaId).toList();
      if (sottocategorie.isNotEmpty) {
        throw 'Non puoi eliminare una macrocategoria che contiene sottocategorie. Elimina prima le sottocategorie.';
      }
    }

    await _firestore.collection('categorie').doc(categoriaId).delete();
  }

  Future<void> eliminaOfferta(String offertaId) async {
    await _firestore.collection('offerte').doc(offertaId).delete();
  }

  Future<void> aggiornaOrdinamentoCategorie(List<Categoria> categorieOrdinate) async {
    final batch = _firestore.batch();
    for (int i = 0; i < categorieOrdinate.length; i++) {
      final categoriaRef = _firestore.collection('categorie').doc(categorieOrdinate[i].id);
      batch.update(categoriaRef, {'ordine': i});
    }
    await batch.commit();
  }

  Future<void> aggiornaOrdinamentoMenu(List<Pietanza> pietanzeOrdinate) async {
    final batch = _firestore.batch();
    for (int i = 0; i < pietanzeOrdinate.length; i++) {
      final pietanzaRef = _firestore.collection('pietanze').doc(pietanzeOrdinate[i].id);
      batch.update(pietanzaRef, {'ordine': i});
    }
    await batch.commit();
  }

  Future<void> aggiornaOrdinamentoOfferte(List<Map<String, dynamic>> offerteOrdinate) async {
    final batch = _firestore.batch();
    for (int i = 0; i < offerteOrdinate.length; i++) {
      final offertaRef = _firestore.collection('offerte').doc(offerteOrdinate[i]['id']);
      batch.update(offertaRef, {'ordine': i});
    }
    await batch.commit();
  }

  Future<int> migraColoriOfferte({int batchSize = 500, bool dryRun = false}) async {
    final snapshot = await _firestore.collection('offerte').get();
    if (snapshot.docs.isEmpty) return 0;

    int updated = 0;
    WriteBatch batch = _firestore.batch();
    int ops = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final colore = data['colore'];
      if (colore is int) {
        try {
          final hex = ColorParser.colorToHex(Color(colore));
          if (!dryRun) {
            batch.update(doc.reference, {'colore': hex});
            ops++;
          }
          updated++;
        } catch (_) {
          // Ignore malformed color values
        }
      }

      if (!dryRun && ops >= batchSize) {
        await batch.commit();
        batch = _firestore.batch();
        ops = 0;
      }
    }

    if (!dryRun && ops > 0) await batch.commit();
    return updated;
  }
}
