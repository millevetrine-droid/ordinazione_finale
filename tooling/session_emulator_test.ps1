# Session lifecycle test against Firestore emulator
# Usage: powershell -ExecutionPolicy Bypass -File tooling\session_emulator_test.ps1

$ErrorActionPreference = 'Stop'

$now = (Get-Date).ToUniversalTime().ToString("o")
$expires = ((Get-Date).ToUniversalTime().AddHours(3)).ToString("o")

$body = @"
{
  "fields": {
    "codice": { "stringValue": "S-AUTO-123" },
    "numeroTavolo": { "integerValue": "9" },
    "idCameriere": { "stringValue": "auto-tester" },
    "createdAt": { "timestampValue": "$now" },
    "expiresAt": { "timestampValue": "$expires" },
    "attiva": { "booleanValue": true }
  }
}
"@

Write-Host "Creating session..."
$created = Invoke-RestMethod -Uri 'http://127.0.0.1:8080/v1/projects/demo-no-project/databases/(default)/documents/sessions' -Method Post -Body $body -ContentType 'application/json'
Write-Host "Created:" (ConvertTo-Json $created -Depth 5)

$docId = ($created.name.Split('/')[-1]).Trim()
Write-Host "DOCID=$docId"

Write-Host "Reading session..."
$read = Invoke-RestMethod -Uri "http://127.0.0.1:8080/v1/projects/demo-no-project/databases/(default)/documents/sessions/$docId" -Method Get
Write-Host (ConvertTo-Json $read -Depth 5)

# Update: set attiva=false and set expiresAt to now
$updateBody = @"
{
  "fields": {
    "attiva": { "booleanValue": false },
    "expiresAt": { "timestampValue": "$now" }
  }
}
"@

Write-Host "Updating session (ending)..."
# Build the patch URI explicitly to avoid accidental parsing/expansion issues with '&' in double-quoted strings
$patchUri = "http://127.0.0.1:8080/v1/projects/demo-no-project/databases/(default)/documents/sessions/$docId" + "?updateMask.fieldPaths=attiva&updateMask.fieldPaths=expiresAt"
Write-Host "PATCH URI: $patchUri"
$patched = Invoke-RestMethod -Uri $patchUri -Method Patch -Body $updateBody -ContentType 'application/json'
Write-Host "Patched:" (ConvertTo-Json $patched -Depth 5)

Write-Host "Reading session after end..."
$read2 = Invoke-RestMethod -Uri "http://127.0.0.1:8080/v1/projects/demo-no-project/databases/(default)/documents/sessions/$docId" -Method Get
Write-Host (ConvertTo-Json $read2 -Depth 5)

Write-Host "DONE"
