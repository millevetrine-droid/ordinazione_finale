# Runbook: Migrazione colori offerte (Menu)

Scopo
---
Procedure sicura per eseguire la migrazione `MenuFirestoreService.migraColoriOfferte()` su un ambiente collegato a Firebase.

Prerequisiti
---
- Accesso alla macchina con il repository clonato.
- Credenziali Firebase:
  - Preferibile: `GOOGLE_APPLICATION_CREDENTIALS` impostata su un file JSON di service account con permessi su Firestore.
  - Alternativa: `gcloud auth application-default login` (richiede gcloud SDK).
- Node: non richiesto. Dart/Flutter installati per eseguire il CLI (`dart` o `flutter run`).
- Backup presente (creato con `tool/backup_repo.ps1`) o snapshot Firestore.

Passi (dry-run consigliato)
---
1) Creare backup locale del repository

```powershell
# Nella root del progetto
.\tool\backup_repo.ps1
```

2) (Opzionale ma raccomandato) Creare snapshot Firestore (console o gcloud/firesotre export)

- Console: Firestore -> Export
- gcloud (se disponibile):

```powershell
# esempio (configura bucket e progetto)
gcloud firestore export gs://<BUCKET_NAME>/backups/$(Get-Date -Format "yyyyMMdd_HHmmss") --project=<PROJECT_ID>
```

3) Verificare credenziali nell'ambiente

```powershell
# verifica variabile
$env:GOOGLE_APPLICATION_CREDENTIALS
# o, se usi gcloud
gcloud auth application-default print-access-token
```

4) Eseguire la migrazione CLI (dry-run & commit)

Al momento lo script `tool/migra_color_offerte.dart` applica direttamente le modifiche. Se vuoi prima un dry-run, posso aggiungere una modalità `--dry-run` che conta i documenti senza modificare.

Per eseguire ora (produzione/dev come deciso):

```powershell
# Assicurati che GOOGLE_APPLICATION_CREDENTIALS sia impostato o che gcloud ADC sia disponibile
dart run tool\migra_color_offerte.dart
```

5) Verifica post-migrazione

- Controlla il numero di documenti aggiornati (output del CLI)
- Esegui query di verifica su alcuni documenti (console Firestore o `firebase` CLI)

```powershell
# Esempio: mostra alcuni documenti con campo colore non-stringa
# (usare console Firestore per ispezione facile)
```

Rollback
---
- Se hai usato `backup_repo.ps1` solo per il codice, non ripristina i dati Firestore. Per il DB reale usa gli snapshot Firestore creati prima dell'operazione.
- Per ripristinare da snapshot Firestore: ripristino con i tool di Google Cloud (console o gcloud import).

Nota su sicurezza
---
- Non eseguire la migrazione su `prod` senza un backup e senza aver testato su dev/staging.
- Preferibile testare prima su un progetto Firebase di sviluppo.

Azioni successive suggerite
---
- (Opzionale) Aggiungere `--dry-run` allo script CLI per contare i documenti modificabili senza scrivere.
- (Opzionale) Log dettagliati in Cloud Logging o file di log locali per audit.
- Creare una branch e PR con i cambiamenti (fatto localmente in seguito).

Contatti
---
Per eseguire la migrazione insieme, conferma l'ambiente target (dev/staging/prod) e fornisci conferma per procedere con l'esecuzione CLI.
