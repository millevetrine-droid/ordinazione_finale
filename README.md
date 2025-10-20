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


