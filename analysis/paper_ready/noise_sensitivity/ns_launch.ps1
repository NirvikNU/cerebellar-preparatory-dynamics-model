param([int]$PreservationPid)
$ErrorActionPreference='Stop'
$repoRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $repoRoot
if($PreservationPid -and (Get-Process -Id $PreservationPid -ErrorAction SilentlyContinue)) { Wait-Process -Id $PreservationPid }
$a=Get-Content 'artifacts/manifests/paper_ready/noise_sensitivity/preservation_before.json' -Raw | ConvertFrom-Json
$b=Get-Content 'results/paper_ready/noise_sensitivity/unit.json' -Raw | ConvertFrom-Json
if($a.status -ne 'PASS' -or $b.status -ne 'PASS'){throw 'Preflight not passed'}
$manifest='artifacts/manifests/paper_ready/noise_sensitivity'
$p=Start-Process 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -WindowStyle Hidden -ArgumentList '-batch',"`"addpath('analysis/paper_ready/noise_sensitivity'); ns_static(pwd,'simulation'); ns_simulate(pwd);`"" -RedirectStandardOutput "$manifest/simulation.stdout.txt" -RedirectStandardError "$manifest/simulation.stderr.txt" -PassThru
Write-Output "Simulation process $($p.Id) launched after both preflight receipts passed."
$p.WaitForExit()
if($p.ExitCode -ne 0){throw "Simulation process failed with exit $($p.ExitCode)"}
Get-Content 'results/paper_ready/noise_sensitivity/simulation.json'
