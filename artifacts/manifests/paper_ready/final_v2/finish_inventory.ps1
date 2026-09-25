$ErrorActionPreference='Stop'
$owners=@(Get-CimInstance Win32_Process -Filter "Name='pwsh.exe'" | Where-Object {
    $_.ProcessId -ne $PID -and $_.CommandLine -like '*& ./artifacts/manifests/paper_ready/final_v2/verify_preservation_resume.ps1*'
})
if($owners.Count -gt 1){throw 'Multiple preservation owners'}
if($owners.Count -eq 1){Wait-Process -Id $owners[0].ProcessId}
$receipt=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'preservation_resume.json') -Raw | ConvertFrom-Json
if($receipt.status -ne 'PASS'){throw 'Preservation did not pass'}
& (Join-Path $PSScriptRoot 'inventory.ps1')
if(-not $?){throw 'Inventory failed'}
