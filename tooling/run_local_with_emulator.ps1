<#
  Script semplice per Windows PowerShell che avvia i Firebase emulator
  in una nuova finestra e poi lancia l'app Flutter nella finestra corrente.
  Eseguire dalla root del progetto: `.	ooling\run_local_with_emulator.ps1`
#>

Param(
    [switch]$RunOnWindows
)

Write-Output "Imposto variabile di progetto e avvio emulatori in una nuova finestra..."
$env:FB_PROJECT_ID = 'demo-no-project'

# Avvia gli emulatori in una nuova finestra separata
$firebaseCmd = "firebase"
$firebaseArgs = "emulators:start --project demo-no-project --config firebase.json --only firestore,auth"
Start-Process -FilePath $firebaseCmd -ArgumentList $firebaseArgs

Write-Output "Attendere qualche secondo perché gli emulatori partano..."
Start-Sleep -Seconds 4

Write-Output "Eseguo flutter run nella finestra corrente (interrompi con Ctrl+C quando vuoi fermare)..."
if ($RunOnWindows) {
    flutter run -d windows
} else {
    flutter run
}

Write-Output "Se vuoi fermare gli emulatori, chiudi la finestra in cui sono stati avviati o torna lì e premi Ctrl+C." 