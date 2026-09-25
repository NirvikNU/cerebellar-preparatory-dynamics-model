$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
Set-Location -LiteralPath $repoRoot
$owners=@(Get-CimInstance Win32_Process -Filter "Name='pwsh.exe'" | Where-Object {
    $_.ProcessId -ne $PID -and $_.CommandLine -like '*& ./artifacts/manifests/paper_ready/final_v2/launch_complete.ps1*'
})
if($owners.Count -gt 1){throw 'Multiple completion owners; stop'}
if($owners.Count -eq 1){Wait-Process -Id $owners[0].ProcessId}
$audit=Get-Content 'results/paper_ready/final_v2/audit.json' -Raw | ConvertFrom-Json
$figures=Get-Content 'artifacts/manifests/paper_ready/final_v2/figures.json' -Raw | ConvertFrom-Json
if($audit.status -ne 'PASS' -or $figures.pairs.Count -ne 6 -or -not(Test-Path 'docs/paper_ready/final_v2/REPORT.md')){throw 'Incomplete production; no final checks started'}
$output=Join-Path $PSScriptRoot 'checks.stdout.txt'
$errorOutput=Join-Path $PSScriptRoot 'checks.stderr.txt'
if((Test-Path -LiteralPath $output) -or (Test-Path -LiteralPath $errorOutput)){throw 'Check logs already exist'}
$run=Start-Process -FilePath 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -WindowStyle Hidden -ArgumentList '-batch',"`"addpath('analysis/paper_ready/final_v2'); v2_control_tables(pwd); v2_output_audit(pwd); v2_packaging_check(pwd);`"" -RedirectStandardOutput $output -RedirectStandardError $errorOutput -PassThru
Write-Output "Saved-output check MATLAB PID $($run.Id); waiting once for completion."
$run.WaitForExit()
Get-Content -LiteralPath $output
Get-Content -LiteralPath $errorOutput
if($run.ExitCode){throw "Saved-output checks exited $($run.ExitCode); stop and preserve evidence"}
& (Join-Path $PSScriptRoot 'preserve.ps1') -Phase after
if(-not $?){throw 'Preservation after failed'}
