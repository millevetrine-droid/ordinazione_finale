Guida rapida per avviare emulatori Firebase e l'app (Windows PowerShell)
=============================================================

Scopo: avviare i emulatori (Firestore + Auth) e lanciare l'app Flutter in modo che tu possa provarla come su uno smartphone.

Prerequisiti minimi:
- Flutter installato e nel PATH
- Firebase CLI installata (comando `firebase`) e loggato

Passi semplici (copiaincolla in PowerShell):

1) Apri una PowerShell nella cartella del progetto e avvia gli emulatori (in una finestra separata):

```powershell
$env:FB_PROJECT_ID = 'demo-no-project'
Start-Process firebase -ArgumentList "emulators:start --project demo-no-project --config firebase.json --only firestore,auth"
```

2) Apri un'altra PowerShell nella stessa cartella e lancia l'app Flutter:

```powershell
flutter clean
flutter pub get
flutter run
```

3) Ora interagisci con l'app sul dispositivo/emulatore Android collegato o sul dispositivo Windows (se disponibile). Prova i pulsanti principali: crea sessione, entra in sessione, logout.

4) Per fermare gli emulatori, torna nella finestra dove sono in esecuzione e premi Ctrl+C.

Se preferisci un singolo script che faccia i passi automaticamente (prova lo script `tooling/run_local_with_emulator.ps1`).

Se hai bisogno, posso eseguire questi comandi per te e poi dirti esattamente quando iniziare a cliccare.
