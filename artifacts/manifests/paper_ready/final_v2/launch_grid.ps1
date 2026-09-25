param([ValidatePattern('^[a-z0-9_]+$')][string]$Attempt='initial')
$ErrorActionPreference='Stop'
$repoRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $repoRoot
$receipt='artifacts/manifests/paper_ready/final_v2/preservation_before.json'
if(-not(Test-Path -LiteralPath $receipt)) {
    $owners=@(Get-CimInstance Win32_Process -Filter "Name='pwsh.exe'" | Where-Object {
        $_.ProcessId -ne $PID -and $_.CommandLine -like '*& ./artifacts/manifests/paper_ready/final_v2/preserve.ps1 -Phase before*'
    })
    if($owners.Count -ne 1){throw 'Cannot identify one preservation owner; do not poll or guess'}
    Wait-Process -Id $owners[0].ProcessId
}
$a=Get-Content -LiteralPath $receipt -Raw | ConvertFrom-Json
$b=Get-Content 'results/paper_ready/final_v2/preflight.json' -Raw | ConvertFrom-Json
if($a.status -ne 'PASS' -or $b.status -ne 'PASS'){throw 'Preservation/preflight not passed'}
$stem=if($Attempt -eq 'initial'){'grid'}else{"grid_$Attempt"}
$output="artifacts/manifests/paper_ready/final_v2/$stem.stdout.txt"
$errorOutput="artifacts/manifests/paper_ready/final_v2/$stem.stderr.txt"
if((Test-Path -LiteralPath $output) -or (Test-Path -LiteralPath $errorOutput)){throw 'Grid launch logs already exist'}
$run=Start-Process -FilePath 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -WindowStyle Hidden -ArgumentList '-batch',"`"addpath('analysis/paper_ready/final_v2'); a=v2_static(pwd,'$stem'); assert(strcmp(a.status,'PASS')); v2_grid(pwd);`"" -RedirectStandardOutput $output -RedirectStandardError $errorOutput -PassThru
Write-Output "Geometry-only MATLAB PID $($run.Id), preservation PASS; waiting once for completion."
$run.WaitForExit()
Get-Content -LiteralPath $output
Get-Content -LiteralPath $errorOutput
if($run.ExitCode){throw "Geometry exited $($run.ExitCode); stop and preserve outputs"}
