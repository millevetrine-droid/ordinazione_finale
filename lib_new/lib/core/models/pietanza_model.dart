/// FILE: pietanza_model.dart
/// SCOPO: Modello dati principale per le pietanze del ristorante con gestione completa di stati, ingredienti, allergeni e metadati
/// 
/// RELAZIONI CON ALTRI FILE:
/// - Importato da: 
///   - inserisci_pietanza_screen.dart (creazione/modifica pietanze)
///   - proprietario_screen.dart (gestione menu proprietario)
///   - staff_screen.dart (visualizzazione staff)
///   - visualizza_cucina_screen.dart (stato ordini cucina)
///   - cameriere_ordine_manuale_screen.dart (ordini manuali cameriere)
///   - archivio_screen.dart (archivio ordini)
///   - tutti i widget che mostrano pietanze (CartItemWidget, PietanzaListItem, ecc.)
///   - menu_provider.dart (gestione stato menu)
///   - ordini_provider.dart (gestione ordini)
/// - Dipendenze: 
///   - enum StatoPietanza
///   - package:flutter/material.dart
/// 
/// FUNZIONALITÀ PRINCIPALI:
/// - Modello dati completo per pietanze con tutti i campi necessari
/// - Gestione stati pietanza (inAttesa, inPreparazione, pronto, servito)
/// - Supporto per emoji e immagini come rappresentazione visiva
/// - Gestione liste ingredienti e allergeni
/// - Metodi di serializzazione toMap/fromMap per persistenza
/// - Getter computati per stato, colori, testi descrittivi
/// - Gestione relazione con categorie e macrocategorie
/// 
/// ULTIME MODIFICHE:
/// - 2024-01-20: AGGIUNTO campo allergeni (List<String>) e relativi getter
/// - 2024-01-20: AGGIUNTO getter haAllergeni e testoAllergeni per facilitare l'uso
/// - 2024-01-20: MANTENUTO campo emoji come String? per backward compatibility
/// 
/// DA VERIFICARE:
/// - Compatibilità con dati esistenti nel database
/// - Type safety tra String? (emoji) e String (nei widget)
/// - Corretto funzionamento dei nuovi getter allergeni
/// - Persistenza corretta del campo allergeni in toMap/fromMap
library;

import 'package:flutter/material.dart';

// === ENUM: STATO PIETANZA ===
// Scopo: Definisce gli stati possibili di una pietanza durante il workflow ordine
// Utilizzo: Gestione del ciclo di vita pietanza da ordinata a servita
enum StatoPietanza {
  inAttesa,      // Pietanza ordinata, in attesa di preparazione
  inPreparazione, // Pietanza in fase di preparazione in cucina
  pronto,        // Pietanza pronta per il servizio
  servito,       // Pietanza servita al tavolo
}

// === CLASSE: PIETANZA ===
// Scopo: Modello dati principale per tutte le pietanze del menu
// Note: Tutti i campi sono final per immutabilità, usa copyWith per modifiche
class Pietanza {
  // === CAMPI IDENTIFICATIVI ===
  final String id;                    // ID univoco pietanza
  final String nome;                  // Nome visualizzato della pietanza
  final String descrizione;           // Descrizione dettagliata
  final double prezzo;                // Prezzo in euro
  
  // === CAMPI VISUALI ===
  final String? emoji;                // Emoji rappresentativa (opzionale)
  final String? imageUrl;             // URL immagine pietanza (opzionale)
  
  // === CAMPI CONTENUTO ===
  final List<String> ingredienti;     // Lista ingredienti principali
  final List<String> allergeni;       // ✅ NUOVO: Lista allergeni presenti
  
  // === CAMPI STATO E DISPONIBILITÀ ===
  final bool disponibile;             // Se la pietanza è disponibile all'ordine
  final StatoPietanza stato;          // Stato corrente nel workflow
  
  // === CAMPI RELAZIONALI ===
  final String? categoriaId;          // ID categoria di appartenenza (opzionale)
  final String macrocategoriaId;      // ID macrocategoria obbligatoria

  // === COSTRUTTORE PRINCIPALE ===
  // Scopo: Crea una nuova istanza di Pietanza con tutti i parametri
  // Note: allergeni ha valore default di lista vuota per backward compatibility
  Pietanza({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.prezzo,
    this.emoji,
    this.imageUrl,
    this.ingredienti = const [],
    this.allergeni = const [], // ✅ NUOVO: campo allergeni con default
    this.disponibile = true,
    this.stato = StatoPietanza.inAttesa,
    this.categoriaId,
    required this.macrocategoriaId,
  });

  // === METODO: COPY WITH ===
  /// Crea una copia della pietanza con campi aggiornati
  /// Utilizzo: Per modifiche immutabili, usare pietanza.copyWith(nuovoValore: x)
  Pietanza copyWith({
    String? id,
    String? nome,
    String? descrizione,
    double? prezzo,
    String? emoji,
    String? imageUrl,
    List<String>? ingredienti,
    List<String>? allergeni, // ✅ NUOVO: parametro allergeni
    bool? disponibile,
    StatoPietanza? stato,
    String? categoriaId,
    String? macrocategoriaId,
  }) {
    return Pietanza(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      prezzo: prezzo ?? this.prezzo,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredienti: ingredienti ?? this.ingredienti,
      allergeni: allergeni ?? this.allergeni, // ✅ NUOVO: copia allergeni
      disponibile: disponibile ?? this.disponibile,
      stato: stato ?? this.stato,
      categoriaId: categoriaId ?? this.categoriaId,
      macrocategoriaId: macrocategoriaId ?? this.macrocategoriaId,
    );
  }

  // === FACTORY: FROM MAP ===
  /// Crea una Pietanza da una mappa (deserializzazione)
  /// Utilizzo: Dal database o localStorage per ricreare l'oggetto
  /// Note: Gestisce i casi di campi mancanti con valori di default
  factory Pietanza.fromMap(Map<String, dynamic> map) {
    // Compatibility: accept multiple field names and enum formats
    final rawStato = map['stato'] ?? map['statoPietanza'];
    StatoPietanza parsedStato;
    if (rawStato is int) {
      parsedStato = StatoPietanza.values[(rawStato < StatoPietanza.values.length) ? rawStato : 0];
    } else if (rawStato is String) {
      parsedStato = StatoPietanza.values.firstWhere(
        (e) => e.toString().split('.').last == rawStato || e.toString() == rawStato,
        orElse: () => StatoPietanza.inAttesa,
      );
    } else {
      parsedStato = StatoPietanza.inAttesa;
    }

    // image field compatibility: imageUrl, immagine, fotoUrl
    final image = map['imageUrl'] ?? map['immagine'] ?? map['fotoUrl'];

    return Pietanza(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      descrizione: map['descrizione'] ?? '',
      prezzo: (map['prezzo'] ?? 0.0).toDouble(),
      emoji: map['emoji'],
      imageUrl: image,
      ingredienti: List<String>.from(map['ingredienti'] ?? []),
      allergeni: List<String>.from(map['allergeni'] ?? []), // ✅ NUOVO: deserializza allergeni
      disponibile: map['disponibile'] ?? true,
      stato: parsedStato,
      categoriaId: map['categoriaId'],
      macrocategoriaId: map['macrocategoriaId'] ?? '',
    );
  }

  // === METODO: TO MAP ===
  /// Converte la Pietanza in mappa (serializzazione)
  /// Utilizzo: Per salvataggio su database o localStorage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'prezzo': prezzo,
      'emoji': emoji,
      'imageUrl': imageUrl,
      'ingredienti': ingredienti,
      'allergeni': allergeni, // ✅ NUOVO: serializza allergeni
      'disponibile': disponibile,
      'stato': stato.index,
      'categoriaId': categoriaId,
      'macrocategoriaId': macrocategoriaId,
    };
  }

  // === GETTER: ALLERGENI ===
  // ✅ NUOVO: Getter per verificare presenza allergeni
  bool get haAllergeni => allergeni.isNotEmpty;
  
  // ✅ NUOVO: Getter per testo allergeni formattato
  String get testoAllergeni => allergeni.join(', ');

  // === GETTER: VISUALIZZAZIONE ===
  /// Restituisce emoji o icona di default se emoji è null
  String get iconaVisualizzata => emoji ?? '🍽️';
  
  /// Verifica se è presente un'immagine
  bool get haFoto => imageUrl != null && imageUrl!.isNotEmpty;

  // === GETTER: RELAZIONI ===
  /// Verifica se la pietanza appartiene a una categoria
  bool get haCategoria => categoriaId != null && categoriaId!.isNotEmpty;

  // === GETTER: STATI SEMPLIFICATI ===
  /// Getter booleani per verificare lo stato corrente
  bool get isInAttesa => stato == StatoPietanza.inAttesa;
  bool get isInPreparazione => stato == StatoPietanza.inPreparazione;
  bool get isPronto => stato == StatoPietanza.pronto;
  bool get isServito => stato == StatoPietanza.servito;

  // === GETTER: TESTI STATO ===
  /// Testo descrittivo per lo stato corrente
  String get statoTesto {
    if (stato == StatoPietanza.inAttesa) return 'In Attesa';
    if (stato == StatoPietanza.inPreparazione) return 'In Preparazione';
    if (stato == StatoPietanza.pronto) return 'Pronto';
    if (stato == StatoPietanza.servito) return 'Servito';
    return 'Sconosciuto';
  }

  // === GETTER: COLORI STATO ===
  /// Colore associato allo stato corrente per UI
  Color get coloreStato {
    if (stato == StatoPietanza.inAttesa) return Colors.orange;
    if (stato == StatoPietanza.inPreparazione) return Colors.blue;
    if (stato == StatoPietanza.pronto) return Colors.green;
    if (stato == StatoPietanza.servito) return Colors.purple;
    return Colors.grey;
  }

  // === GETTER: PERCORSO ===
  /// Stringa che rappresenta il percorso gerarchico della pietanza
  String get percorsoCompleto {
    if (haCategoria) {
      return '$macrocategoriaId > $categoriaId';
    }
    return macrocategoriaId;
  }
}