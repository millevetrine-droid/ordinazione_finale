# Merge runbook — unire `lib/` e `lib_new/lib/`

Scopo
- Fornire una strategia sicura, ripetibile e verificabile per unire le funzionalità di `lib_new/lib/` dentro il codice principale `lib/` mantenendo la possibilità di rollback e test continui.

Piccola "contract" (input/output)
- Input: codice sorgente nelle cartelle `lib/` (codice corrente) e `lib_new/lib/` (nuova versione/fork).
- Output: una base di codice unificata sotto `lib/` (o `lib_merged/` temporanea) compilabile, con test e analyzer verdi.
- Modalità errore: merge parziale salvato in branch separato; backup del repo creato prima di cambi distruttivi.

Edge cases principali
- File con stesso path relativo ma API differenti (es. `menu_service.dart`).
- Provider/Service duplicati con state distinto (es. `MenuProvider`, `MenuService`).
- Modifiche a modelli JSON/Firestore incompatibili tra le versioni.
- Risorse (assets, strings, localizations) con nomi uguali ma contenuto diverso.

Strategia passo-passo (high level)
1. Inventory: generare report di sovrapposizioni e elenco provider/classes/servizi per valutare conflitti (script incluso).
2. Scegliere la base canonica: decidere se portare `lib_new` in `lib/` (raccomandato) o mantenere `lib_new` e adattare `lib/` verso `lib_new`.
3. Consolidamento delle dipendenze: unire `pubspec.yaml` (versioni, plugin, assets) in branch separato e `dart pub get`.
4. Unire i servizi/core logic prima delle UI: consolidare `services/`, `core/`, `models/`, `repositories/` — questo minimizza cambi necessari nelle view.
5. Consolidare providers e stato: mappare provider affini (es. `MenuProvider` in `lib_new` vs eventuale `MenuProvider` in `lib`) e scegliere l'implementazione canonica.
6. UI merge: spostare/integrare schermate una ad una, eseguire build/test dopo ogni gruppo di schermate.
7. Test & linting: eseguire `flutter analyze` e `flutter test` frequentemente; correggere errori via piccoli commit.
8. QA manuale: avviare l'app su device/emulatore, testare flussi critici (login, menu, checkout, cucina, sala).
9. Cleanup: rimuovere codice/deps non usati, aggiornare README e runbook.

Ordine di lavoro raccomandato (mini-sprint)
- Sprint 0 (giorno 0): Inventory + report duplicati (script `tool/find_duplicates.ps1`).
- Sprint 1 (1–2 giorni): Consolidare `core/services` e `models` → assicurarsi che i servizi Firestore/HTTP usino gli stessi nomi e contratti.
- Sprint 2 (1–2 giorni): Unire providers/state (cart, auth, sessione, ordini) e verificare runtime con test unitari mirati.
- Sprint 3 (2–3 giorni): Integrare UI (start dal login, menu, cart, checkout), fixare regressioni e ripetere test.

Checklist tecnica (per ogni file/feature migrata)
- [ ] Creare branch feature/merge-xxxx
- [ ] Aggiornare `pubspec.yaml` se necessario e `dart pub get`
- [ ] Eseguire `flutter analyze` → correggere errori
- [ ] Eseguire `flutter test` → risolvere fallimenti
- [ ] Eseguire l'app manualmente e verificare i flussi interessati
- [ ] Commit e push su branch, aprire PR per code review

Script utili
- `tool/find_duplicates.ps1` — rileva file con stesso percorso relativo in `lib/` e `lib_new/lib/` (esegui in PowerShell dalla root del repo).

Verifica finale
- Tutti i test passano
- `flutter analyze` non segnala errori
- Smoke test manuale dei flussi critici

Note su rollback
- Mantieni sempre un backup del repo (zip) e lavora su branch. Se qualcosa va male, ripristina dallo zip o resetta il branch.

Contatto rapido: se vuoi, posso eseguire Sprint 0 ora (generare i report e un PR con il piano di merge dettagliato). Altrimenti dimmi quale sprint vuoi che faccia io per primo.
