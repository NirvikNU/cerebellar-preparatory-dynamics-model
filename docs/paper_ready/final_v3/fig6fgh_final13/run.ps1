param([ValidateSet('run','finish')][string]$Phase='run')
$ErrorActionPreference='Stop'
$taskRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$taskDocs=Join-Path $taskRoot 'docs/paper_ready/final_v3/fig6fgh_final13'
$taskOut=Join-Path $taskDocs ($Phase+'_stdout.log')
$taskErr=Join-Path $taskDocs ($Phase+'_stderr.log')
if((Test-Path -LiteralPath $taskOut) -or (Test-Path -LiteralPath $taskErr)){throw 'Preserve existing logs'}
$taskExpression="cd('$($taskRoot.Replace('\','/'))'); addpath('analysis/paper_ready/final_v3/fig6fgh_final13'); fd13_$Phase(pwd);"
$taskJob=Start-Process -FilePath 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -ArgumentList @('-batch',('"'+$taskExpression+'"')) -WindowStyle Hidden -PassThru -RedirectStandardOutput $taskOut -RedirectStandardError $taskErr
$taskJob.WaitForExit()
Get-Content -LiteralPath $taskOut
Get-Content -LiteralPath $taskErr
if($taskJob.ExitCode -ne 0){throw "Display-only job failed: $($taskJob.ExitCode)"}
