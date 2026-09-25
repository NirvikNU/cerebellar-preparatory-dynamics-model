$ErrorActionPreference='Stop'
$repoRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $repoRoot
$owners=@(Get-CimInstance Win32_Process -Filter "Name='pwsh.exe'" | Where-Object {
    $_.ProcessId -ne $PID -and $_.CommandLine -like '*& ./artifacts/manifests/paper_ready/final_v2/launch_grid.ps1*'
})
if($owners.Count -gt 1){throw 'Multiple geometry owners; stop'}
if($owners.Count -eq 1){Wait-Process -Id $owners[0].ProcessId}
$selection=Get-Content 'results/paper_ready/final_v2/geometry_selection.json' -Raw | ConvertFrom-Json
$unit=Get-Content 'results/paper_ready/final_v2/unit.json' -Raw | ConvertFrom-Json
if($selection.status -ne 'FROZEN' -or $unit.status -ne 'PASS'){throw 'Geometry or corrected-baseline unit gate not passed'}
$output='artifacts/manifests/paper_ready/final_v2/completion.stdout.txt'
$errorOutput='artifacts/manifests/paper_ready/final_v2/completion.stderr.txt'
if((Test-Path -LiteralPath $output) -or (Test-Path -LiteralPath $errorOutput)){throw 'Completion launch logs already exist'}
$run=Start-Process -FilePath 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -WindowStyle Hidden -ArgumentList '-batch',"`"addpath('analysis/paper_ready/final_v2','figures/paper_ready/final_v2'); a=v2_static(pwd,'production'); assert(strcmp(a.status,'PASS')); v2_simulate(pwd); v2_analyze(pwd); v2_audit(pwd); v2_readiness(pwd); v2_sources(pwd); v2_figures(pwd); v2_report(pwd);`"" -RedirectStandardOutput $output -RedirectStandardError $errorOutput -PassThru
Write-Output "Completion MATLAB PID $($run.Id), frozen geometry/units PASS; waiting once for completion."
$run.WaitForExit()
Get-Content -LiteralPath $output
Get-Content -LiteralPath $errorOutput
if($run.ExitCode){throw "Completion exited $($run.ExitCode); stop and preserve outputs"}
