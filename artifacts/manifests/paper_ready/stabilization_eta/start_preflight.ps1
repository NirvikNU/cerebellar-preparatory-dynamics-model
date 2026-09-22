$ErrorActionPreference='Stop'
$etaRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
# One native completion wait for the already-started preservation process;
# no file/log/status polling loop and no second inventory run.
$etaOwners=@(Get-CimInstance Win32_Process | Where-Object {
    $_.ProcessId -ne $PID -and $_.Name -in @('pwsh.exe','powershell.exe') -and
    $_.CommandLine -like '*resume_preserve.ps1*' -and $_.CommandLine -notlike '*Get-CimInstance*'
})
if($etaOwners.Count -gt 1){throw 'Preservation process identity is ambiguous'}
if($etaOwners.Count -eq 1){Wait-Process -Id $etaOwners[0].ProcessId}
$etaGuard=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RESUME_INVENTORY.json') -Raw | ConvertFrom-Json
if($etaGuard.status -ne 'PASS'){throw 'Preservation has not passed'}
$etaCommand=@"
root='$($etaRoot.Replace('\','/'))'; addpath(fullfile(root,'analysis','paper_ready'),fullfile(root,'analysis','paper_ready','stabilization_eta')); maxNumCompThreads(1); files=dir(fullfile(root,'analysis','paper_ready','stabilization_eta','*.m')); checks=cell(numel(files),1); for k=1:numel(files), checks{k}=checkcode(fullfile(files(k).folder,files(k).name),'-id'); end; disp(jsonencode(checks)); assert(all(cellfun(@isempty,checks)),'Code Analyzer messages require review'); p=fullfile(root,'artifacts','manifests','paper_ready','stabilization_eta','STATIC_PREFLIGHT.json'); assert(~isfile(p)); paper_json(p,struct('status','PASS','files',{{files.name}})); try, eta_baseline(root); catch err, dest=fullfile(root,'artifacts','manifests','paper_ready','stabilization_eta','BASELINE_STOP.json'); assert(~isfile(dest)); paper_json(dest,struct('status','STOP','identifier',err.identifier,'message',err.message,'stack',err.stack)); rethrow(err); end
"@
& 'C:/Program Files/MATLAB/R2025b/bin/matlab.exe' -batch $etaCommand
if($LASTEXITCODE -ne 0){throw "MATLAB preflight failed with exit $LASTEXITCODE"}
Get-Content -LiteralPath (Join-Path $etaRoot 'results/paper_ready/stabilization_eta/baseline.json')
