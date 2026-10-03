$ErrorActionPreference = 'Stop'
$taskRoot = 'E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$taskDocs = Join-Path $taskRoot 'docs/paper_ready/final_v3/fig6fgh_success10'
$matlabBatch = "cd('$($taskRoot.Replace('\','/'))'); addpath('analysis/paper_ready/final_v3/fig6fgh_success10'); sp10_run(pwd);"
$run = Start-Process -FilePath 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -ArgumentList @('-batch',('"'+$matlabBatch+'"')) -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $taskDocs 'matlab_stdout.log') -RedirectStandardError (Join-Path $taskDocs 'matlab_stderr.log')
$run.WaitForExit()
Get-Content -LiteralPath (Join-Path $taskDocs 'matlab_stdout.log')
Get-Content -LiteralPath (Join-Path $taskDocs 'matlab_stderr.log')
if ($run.ExitCode -ne 0) { throw "MATLAB display-only run failed with exit code $($run.ExitCode)" }
