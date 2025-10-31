Firestore rules and local testing
=================================

Ho aggiunto un file di regole minimale `firestore.rules` per la collection `sessions` e aggiornato `firebase.json` per puntare a questo file quando si usa l'emulatore.

Regole principali (sintesi):
- Solo utenti autenticati con custom claim `role == 'staff'` (o `staff == true`) possono creare, aggiornare o cancellare sessioni.
- I client non-autenticati possono leggere (get/list) una sessione solo se `attiva == true` e `expiresAt > request.time`.

File aggiunti / modificati:
- `firestore.rules` (nuovo) — regole Firestore per `sessions/{sessionId}`.
- `firebase.json` (modificato) — ora include la proprietà `firestore.rules` per l'emulatore.

Come testare localmente con l'emulatore Firebase
-------------------------------------------------
Assumendo di avere l'SDK Firebase CLI installato e configurato, dalla root del progetto esegui:

```powershell
# Avvia gli emulatori (assicurati di essere nella root del progetto)
firebase emulators:start --only firestore
```

L'emulatore caricherà `firestore.rules` automaticamente (grazie al riferimento in `firebase.json`).

Test manuale rapido con `gcloud`/curl (opzionale):
- Puoi usare la libreria client o le API REST dell'emulatore per creare una sessione. Per le operazioni che richiedono autorizzazione staff, è necessario passare un token simulato con claim `role: 'staff'`.

Suggerimento per test automatizzati (raccomandato):
- Scrivere test che usino il Firebase Emulator e SDK (Node/Python/Dart) per:
  1. Verificare che una richiesta anonima non possa creare una sessione (dev'essere negata).
  2. Verificare che una richiesta con custom claim `role:'staff'` possa creare una sessione.
  3. Verificare che un client anonimo possa leggere una sessione attiva/non scaduta.

Note sulla sicurezza
--------------------
Queste regole sono intenzionalmente semplici per coprire lo use-case della demo. Per produzione valutare:
- Mapping dei ruoli e gestione claims (es. claim `role`/`staff` impostati dal backend).
- Limitare l'accesso alle operazioni di update (permettere solo a staff di chiudere la sessione).
- Logging e auditing delle creazioni/terminazioni di sessione.
