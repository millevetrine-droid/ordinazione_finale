#!/usr/bin/env pwsh
<#
  Script semplice per creare un backup zip della workspace.
  Salva il file in ./backups/ordinazione-backup-<timestamp>.zip
  Uso: aprire PowerShell, posizionarsi nella root del progetto e lanciare:
    .\tool\backup_repo.ps1
#>

$root = Resolve-Path "$PSScriptRoot\.."
$backupDir = Join-Path $root 'backups'
if (-Not (Test-Path $backupDir)) {
  New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
# Use a unique suffix (PID + short GUID) to avoid collisions with files in use
$unique = "${([System.Diagnostics.Process]::GetCurrentProcess().Id)}-${([System.Guid]::NewGuid().ToString('N').Substring(0,8))}"
$dest = Join-Path $backupDir "ordinazione-backup-$timestamp-$unique.zip"

# Exclude common heavy/irrelevant folders to keep the backup small and avoid
# packaging build artifacts or IDE caches.


$exclude = @()
$exclude += Join-Path $root 'build'
$exclude += Join-Path $root 'android\build'
$exclude += Join-Path $root '.gradle'
$exclude += Join-Path $root 'ios\Pods'
$exclude += Join-Path $root 'backups'

$items = Get-ChildItem -Path $root -Force | Where-Object {
  $full = $_.FullName
  # Exclude any path that is inside one of the exclude folders
  -not ($exclude | Where-Object { $full.StartsWith($_, [System.StringComparison]::InvariantCultureIgnoreCase) })
}

$paths = $items | ForEach-Object { $_.FullName }

if ($paths.Count -eq 0) {
  Write-Host "Nessun file da comprimere. Backup non creato." -ForegroundColor Yellow
  exit 1
}

function Try-Compress {
  param($paths, $dest, $attempts = 3)
  for ($i = 1; $i -le $attempts; $i++) {
    try {
      Compress-Archive -Path $paths -DestinationPath $dest -Force
      return $true
    } catch {
      Write-Host "Compress-Archive attempt $i failed: $($_.Exception.Message)" -ForegroundColor Yellow
      Start-Sleep -Seconds (2 * $i)
    }
  }
  return $false
}

if (Try-Compress -paths $paths -dest $dest -attempts 3) {
  Write-Host "Backup creato: $dest"
} else {
  Write-Host "Errore: impossibile creare il backup dopo diversi tentativi" -ForegroundColor Red
  exit 1
}
