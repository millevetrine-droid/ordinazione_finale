# Helper PowerShell script: seed Firestore emulator
# Usage: apri PowerShell nella root del progetto e esegui: .\tool\seed_emulator.ps1

# Controlla se la porta dell'emulator è attiva
$hostPort = 'localhost'
$hostPortNum = 8080

Write-Host "Controllo emulator Firestore su ${hostPort}:${hostPortNum}..."

try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect($hostPort, $hostPortNum)
    $tcp.Close()
    Write-Host "Emulator attivo. Eseguo il seed..."

    npm install firebase-admin
    $env:FIRESTORE_EMULATOR_HOST = "${hostPort}:${hostPortNum}"
    $env:FIREBASE_PROJECT_ID = 'demo-project'
    node .\tool\seed_firestore.js
} catch {
    Write-Host "Impossibile connettersi all'emulator su ${hostPort}:${hostPortNum}. Avvia prima: firebase emulators:start --only firestore" -ForegroundColor Red
}
