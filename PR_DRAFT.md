# PR Draft: consolidate Points & Offerte into lib_new

## Titolo
chore(migration): consolidate Points & Offerte in lib_new; add docs and shims

## Breve descrizione

Questo PR mira a rendere `lib_new/` la baseline canonica del codice dell'app.
Le implementazioni per Points e Offerte sono state consolidate sotto `lib_new/`.
Per mantenere retrocompatibilità con import legacy, sono stati aggiunti shim/adapter
in `lib/` che delegano alle implementazioni in `lib_new`.

Modifiche principali:

- Consolidamento dei servizi Points/Offerte in `lib_new/lib/core/services`.
- Shim e adapter in `lib/` per mantenere compatibilità con codice esistente.
- Hardened model parsing (`Ordine`, `Pietanza`, `Categoria`, `Macrocategoria`) per
  accettare formati legacy (Timestamp/String/int, varianti di chiavi immagine).
- Fix analyzer warnings e miglioramenti minori (interpolation, mounted guards).
- Aggiunta di test offline per Points/Offerte/Ordini (fake_cloud_firestore).
- Documentazione breve sulla migrazione aggiunta in `README.md`.

## File rilevanti (high level)

- `lib_new/lib/core/services/point_service.dart`
- `lib_new/lib/core/services/menu_services/menu_firestore_service.dart`
- `lib/services/firebase/points_service.dart` (shim)
- `lib/adapters/offerta_adapter.dart` (normalizzazione)
- `lib/core/models/*` (hardened fromMap implementations)
- `README.md` (nota migrazione `lib_new`)

## Test eseguiti

- Eseguita la suite completa di test locali: `flutter test` — tutti i test sono passati.
- `flutter analyze --no-pub` — no issues found.

## Checklist prima di aprire PR remoto

- [x] Branch locale creato: `feature/migration/lib_new`
- [x] Commit dei cambi rilevanti in branch
- [ ] Push branch al remote (richiesto)
- [ ] Creare PR draft su GitHub o altra piattaforma

## Comandi suggeriti (PowerShell)

```powershell
# Aggiungi remote se manca (sostituisci con il tuo URL remoto)
git remote add origin https://github.com/tuo-user/ordinazione.git

# Push del branch e creazione PR (dopo il push puoi usare GH CLI per aprire la PR)
git push -u origin feature/migration/lib_new

# Se hai GitHub CLI:
gh pr create --fill --base main --head feature/migration/lib_new
```

## Note per i reviewer

- `lib_new` è la baseline: rivedere le implementazioni canoniche sotto `lib_new/lib`.
- Gli shim in `lib/` mantengono retrocompatibilità — la loro rimozione è opzionale
  e dovrebbe avvenire solo dopo che tutti i riferimenti legacy sono aggiornati.
- Ho aggiunto una sezione nel `README.md` che spiega dove trovare le implementazioni
  e come procedere con la migrazione. Vedi `README.md` per comandi e indicazioni.

---

Se vuoi, provo a fare il push al remote se mi fornisci l'URL del repository o
configuri `origin` qui; altrimenti incolla i comandi PowerShell sopra e apri la PR.
