# ordinazione

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Migrazione colori offerte

Per uniformare i colori delle offerte in Firestore al formato `#AARRGGBB` ho aggiunto
una utility di migrazione e una schermata di debug che puoi usare in ambienti di
sviluppo.

- Schermata debug: `lib/screens/debug/migra_color_offerte_screen.dart`.
- Metodo di servizio: `MenuFirestoreService.migraColoriOfferte()`.

Istruzioni rapide per eseguire la migrazione localmente:

1. Avvia l'app in modalità debug col tuo emulatore o dispositivo (connesso a Firebase con le credenziali di sviluppo).
2. Aggiungi una route temporanea nel file `main.dart` o nel navigator dell'app che punti a `MigraColoriOfferteScreen`.
3. Apri la schermata e premi `Esegui migrazione`.

La migrazione è idempotente: aggiorna solo i documenti che hanno `colore` come intero.

## Backup repository

Per fare un backup rapido della workspace puoi eseguire lo script PowerShell incluso:

```powershell
.\tool\backup_repo.ps1
```

Il backup sarà scritto in `./backups/` con timestamp.

Nota sulla sicurezza e le credenziali:

- Lo script CLI `tool/migra_color_offerte.dart` modifica i documenti Firestore. Prima di eseguirlo, assicurati di avere:
	- credenziali di servizio o un account utente con permessi di scrittura sul progetto Firebase di destinazione disponibili nell'ambiente (es. GOOGLE_APPLICATION_CREDENTIALS per le service account o l'autenticazione gcloud attiva);
	- eseguito un backup (usando `.\tool\backup_repo.ps1` o una snapshot Firestore) su cui ritornare in caso di problemi.

Esempi (PowerShell):

```powershell
# Crea un backup della workspace (salva in ./backups/)
.\tool\backup_repo.ps1

# Esegui la migrazione con il CLI Dart (assicurati che le credenziali siano disponibili)
dart run tool\migra_color_offerte.dart
```

Se non hai le credenziali nell'ambiente, è preferibile lanciare la migrazione da un ambiente di sviluppo già autenticato (emulatore o dispositivo con Firebase configurato) oppure eseguire la migrazione tramite l'interfaccia di debug in-app.

## Eseguire la migrazione da CLI

Se preferisci non aprire l'app, esiste uno script Dart CLI che chiama la migrazione
direttamente (richiede che l'ambiente sia configurato con le credenziali Firebase):

```powershell
dart run tool\migra_color_offerte.dart
```

Assicurati di eseguire questi comandi in ambiente di sviluppo e di avere i permessi
necessari per modificare i documenti Firestore.

Opzioni utili del CLI:

```powershell
# Conta i documenti che verrebbero aggiornati (nessuna scrittura)
dart run tool\migra_color_offerte.dart --dry-run

# Stampa un campione dei primi 10 documenti (mostra il campo `colore` grezzo)
dart run tool\migra_color_offerte.dart --sample 10

# Esegue la migrazione reale (scrive su Firestore)
dart run tool\migra_color_offerte.dart
```

## Nota sulla migrazione `lib_new` (baseline) 🛠️

Stato attuale della migrazione:

- `lib_new/` è la baseline canonica del codice. Le nuove implementazioni per
	Points e Offerte sono state consolidate sotto `lib_new/lib/core/services`.
- Per mantenere compatibilità con il codice legacy, sono presenti degli shim e
	adapter nella cartella `lib/` che delegano alle implementazioni in `lib_new`.

Dove guardare (file rilevanti):

- Implementazioni canonicali:
	- `lib_new/lib/core/services/point_service.dart` (PointsService)
	- `lib_new/lib/core/services/menu_services/menu_firestore_service.dart` (Offerte)
	- `lib_new/lib/presentation/pages/regalo_punti_screen.dart` (UI Regala Punti)
	- `lib_new/lib/presentation/pages/gestione_offerte_controller.dart` (controller Offerte)

- Shim / adapter legacy:
	- `lib/services/firebase/points_service.dart` (shim delega a `lib_new`)
	- `lib/adapters/offerta_adapter.dart` (normalizzazione offerta)

Come lavorare con la baseline `lib_new`:

1. Sviluppa e testa le modifiche dentro `lib_new/`.
2. Usa gli shim in `lib/` per mantenere retrocompatibilità con import legacy
	 finché non sei pronto a rimuoverli.
3. Prima di rimuovere uno shim:
	 - Assicurati che tutti i riferimenti legacy siano aggiornati.
	 - Esegui la suite di test (`flutter test`) e `flutter analyze`.
	 - Crea un backup (`tool/backup_repo.ps1`) e apri una PR con un changelog chiaro.

Comandi utili locali (PowerShell):

```powershell
# Crea un branch per la merge/migrazione
git checkout -b feature/migration/lib_new

# Esegui analyzer e test
C:\src\flutter\flutter\bin\flutter.bat analyze --no-pub
C:\src\flutter\flutter\bin\flutter.bat test

# Crea commit e push (remote configurato)
git add -A
git commit -m "chore(migration): document lib_new baseline and shims; add migration notes"
git push -u origin feature/migration/lib_new
```

Note finali:

- Ho già eseguito i test offline per Points/Offerte/Ordini e l'analyzer è "clean"
	in questa working copy. Se vuoi, preparo una PR draft o procedo con la rimozione
	degli shim (passo rischioso: lo faccio solo dopo tuo OK).


## Stato merge (28-10-2025)

La migrazione contenuta in `feature/migration/lib_new_on_main` è stata unita
in `main` il 28 ottobre 2025. La suite di unit test è passata sul branch PR e
su `main` dopo il merge. La CI usa la workflow `./github/workflows/flutter_test.yml`.

Se volete rimuovere permanentemente i backup storici (`lib_backup_*`, `lib_merged_*`)
posso preparare un piano di riscrittura della storia (BFG/git-filter-repo). Questo
comporta un force-push e coordinazione con i collaboratori; lo eseguo solo dopo
approvazione esplicita.



