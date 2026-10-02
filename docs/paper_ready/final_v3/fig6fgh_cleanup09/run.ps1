param([ValidateSet('initial','initial_r1','smoke')][string]$Phase)
$ErrorActionPreference='Stop'
$repo09='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$out09=Join-Path $PSScriptRoot ($Phase+'.stdout.log'); $err09=Join-Path $PSScriptRoot ($Phase+'.stderr.log')
if((Test-Path -LiteralPath $out09) -or (Test-Path -LiteralPath $err09)){throw 'Preserve existing process logs'}
$expr09="cd('$($repo09.Replace('\','/'))'); addpath('analysis/paper_ready/final_v3/fig6fgh_cleanup09'); mv09_run(pwd,'$Phase');"
$proc09=Start-Process -FilePath 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -ArgumentList @('-batch',('"'+$expr09+'"')) -WorkingDirectory $repo09 -WindowStyle Hidden -RedirectStandardOutput $out09 -RedirectStandardError $err09 -PassThru
$proc09.WaitForExit()
Get-Content -LiteralPath $out09; Get-Content -LiteralPath $err09
if($proc09.ExitCode -ne 0){throw "Display/validation failed: $($proc09.ExitCode)"}
