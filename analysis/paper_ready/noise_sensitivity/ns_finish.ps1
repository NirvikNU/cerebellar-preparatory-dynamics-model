param([int]$SimulationHostPid)
$ErrorActionPreference='Stop'
$repoRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $repoRoot
if($SimulationHostPid -and (Get-Process -Id $SimulationHostPid -ErrorAction SilentlyContinue)) { Wait-Process -Id $SimulationHostPid }
$a=Get-Content 'results/paper_ready/noise_sensitivity/simulation.json' -Raw | ConvertFrom-Json
if($a.status -ne 'PASS'){throw 'No passed simulation receipt; analysis not started'}
$manifest='artifacts/manifests/paper_ready/noise_sensitivity'
$p=Start-Process 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -WindowStyle Hidden -ArgumentList '-batch',"`"addpath('analysis/paper_ready/noise_sensitivity','figures/paper_ready/noise_sensitivity'); ns_static(pwd,'final'); ns_analyze(pwd); ns_audit(pwd); ns_tables(pwd); ns_table_audit(pwd); ns_figures(pwd); ns_report(pwd);`"" -RedirectStandardOutput "$manifest/completion.stdout.txt" -RedirectStandardError "$manifest/completion.stderr.txt" -PassThru
Write-Output "Analysis/audit process $($p.Id) launched after passed simulation receipt."
$p.WaitForExit()
if($p.ExitCode -ne 0){throw "Completion process failed with exit $($p.ExitCode)"}
& pwsh -NoProfile -File analysis/paper_ready/noise_sensitivity/ns_preservation.ps1 after
if($LASTEXITCODE -ne 0){throw 'Final preservation failed'}
Get-Content 'results/paper_ready/noise_sensitivity/audit.json'
