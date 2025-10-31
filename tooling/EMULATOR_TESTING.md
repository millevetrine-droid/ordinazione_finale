# Firestore emulator — testing sessions flow (Windows / PowerShell)

Questa guida breve spiega come riavviare il Firestore Emulator in modo che carichi `firestore.rules` e come eseguire lo script di test REST `tooling/session_emulator_test.ps1` che verifica il lifecycle di una sessione (create → read → end → read).

Prerequisiti
- `firebase-tools` installato (globalmente o via `npx`).
- Java (se richiesto dalla versione dell'emulator).
- Emulatore non già in esecuzione (se è in esecuzione, fermalo prima).

1) Verifica che `firebase.json` punti a `firestore.rules`

Apri `firebase.json` e verifica che contenga la riga:

```json
"firestore": { "rules": "firestore.rules" }
```

Se è presente, l'emulator caricherà le regole all'avvio.

2) Avvia / riavvia l'emulatore (PowerShell)

Dal root del progetto (`c:\Users\Anselmo\Documents\ordinazione`) esegui (PowerShell):

```powershell
# Ferma l'emulatore se è in esecuzione (usa il terminale dove è partito)
# Poi avvia nella root del progetto; in PowerShell è consigliabile mettere il valore di --only tra virgolette
firebase emulators:start --config firebase.json --only "firestore"

# Se vuoi avviare anche Auth insieme:
firebase emulators:start --config firebase.json --only "firestore,auth"

# oppure, se usi npx:
npx firebase emulators:start --config firebase.json --only "firestore,auth"
```

Nota: l'emulator dovrebbe loggare "All emulators ready" e Firestore su `127.0.0.1:8080`.

3) Esegui lo script di test REST (PowerShell)

Nel repository esiste lo script `tooling/session_emulator_test.ps1` che esegue 4 step: create -> read -> patch(end) -> read e stampa i risultati.


Esegui (PowerShell):

```powershell
cd 'c:\Users\Anselmo\Documents\ordinazione'
# Esegui lo script PowerShell che testa il lifecycle via REST (anonimo)
powershell -ExecutionPolicy Bypass -File tooling\session_emulator_test.ps1

# Oppure esegui lo script Node che testa le regole usando l'Auth emulator
cd tooling
npm run test:emulator
```

Osservazioni sui risultati attesi:
- Se l'emulator ha caricato `firestore.rules` e queste richiedono autenticazione per la `create`, una richiesta REST anonima (senza token) riceverà `403`.
- Lo script attuale usa chiamate REST non-autenticate — se vuoi testare le regole come staff dovrai:
  - avviare anche l'Auth Emulator e generare un token con custom claim `role: 'staff'`, oppure
  - usare uno script di test che utilizza l'SDK admin (firebase-admin) puntando all'emulator (in questo caso le regole NON verranno applicate perché l'admin bypassa le regole).

4) Testare le regole come staff (opzioni)
- Opzione A (più fedele alle regole): avvia Auth emulator e usa le API dell'Auth emulator per creare un utente, poi esegui le richieste Firestore con le credenziali di quell'utente. Questo richiede un piccolo script che scambi le credenziali per un token e lo passi in `Authorization: Bearer <token>` nelle chiamate REST.
- Opzione B (veloce, per CI/admin): usa `firebase-admin` con `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080` per fare create/update (l'admin bypassa le regole quindi è utile per preparare dati di test ma non per verificare le regole).

5) Se vuoi che esegua io questi passaggi:
- Posso: riavviare l'emulator (modificando `firebase.json` è già puntato a `firestore.rules`), quindi eseguire lo script di test e riportare output.
- Oppure posso creare un piccolo script Node (`tooling/session_emulator_admin.js`) che usa `firebase-admin` per creare e terminare la sessione contro l'emulator (utile per CI).

Se vuoi che proceda ora, dimmi se preferisci che usi l'approccio "Admin (bypass rules)" per verificare il flusso o l'approccio "Auth-emulator + staff token" per verificare anche l'applicazione delle regole. Posso eseguire i comandi e riassumere i risultati uno step alla volta.
