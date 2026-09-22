$ErrorActionPreference = 'Stop'
$taskRoot = 'E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $taskRoot
$matlabExpression = "maxNumCompThreads(1); addpath(fullfile(pwd,'analysis','paper_ready','stabilization_eta')); files=dir(fullfile(pwd,'analysis','paper_ready','stabilization_eta','*.m')); for j=1:numel(files), msgs=checkcode(fullfile(files(j).folder,files(j).name),'-id'); assert(isempty(msgs),jsonencode(msgs)); end; eta_simulate(pwd);"
& 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -batch $matlabExpression -logfile 'artifacts/manifests/paper_ready/stabilization_eta/production.log'
exit $LASTEXITCODE
