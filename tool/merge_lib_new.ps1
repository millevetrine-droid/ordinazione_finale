<#
Safe merge script: copies files from lib_new/lib into lib preserving backups.
Run this script in PowerShell from project root to perform the merge.
Usage: .\tool\merge_lib_new.ps1
#>
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = Join-Path -Path $PSScriptRoot -ChildPath "../lib_backup_pre_merge_$timestamp"
Write-Host "Creating backup of current lib/ at: $backupDir"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Copying current lib/ files to backup..."
Copy-Item -Path "$(Resolve-Path .\lib)\*" -Destination $backupDir -Recurse -Force

Write-Host "Copying lib_new/lib contents into lib/ (will overwrite files with same relative path)..."
$src = Resolve-Path .\lib_new\lib
$dst = Resolve-Path .\lib
Copy-Item -Path "$src\*" -Destination $dst -Recurse -Force

Write-Host "Merge complete. Run 'flutter pub get' and 'flutter analyze' next."