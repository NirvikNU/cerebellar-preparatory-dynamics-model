$ErrorActionPreference = 'Stop'
$taskRoot = 'E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $taskRoot
$matlabExpression = "maxNumCompThreads(1); addpath(fullfile(pwd,'analysis','paper_ready','stabilization_eta'),fullfile(pwd,'figures','paper_ready','stabilization_eta')); receipt=eta_static(pwd); assert(strcmp(receipt.status,'PASS')); cfg=eta_paths(pwd); paper_json(fullfile(cfg.manifest,'PRODUCTION_STATIC.json'),receipt); eta_analyze(pwd); eta_audit(pwd); eta_report(pwd); eta_figures(pwd);"
& 'C:\Program Files\MATLAB\R2025b\bin\matlab.exe' -batch $matlabExpression -logfile 'artifacts/manifests/paper_ready/stabilization_eta/analysis.log'
exit $LASTEXITCODE
