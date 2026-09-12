param([ValidateSet('Inventory','Remove','Verify')][string]$Mode='Inventory')
$ErrorActionPreference='Stop'
$postgoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$postgoInventory=Join-Path $PSScriptRoot 'POSTGO_CLEANUP_INVENTORY.csv'
$postgoBaseline=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'POSTGO_INPUTS_BEFORE.csv')
$postgoRetire=@(
    'run_stage_3_finalize.m',
    'artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_PREFLIGHT_STOP.md',
    'artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_IMPLEMENTATION_STOP.md',
    'artifacts/manifests/stage3_cortical_state_feasibility/BIO_STOP_REPORT.md',
    'artifacts/manifests/stage3_cortical_state_feasibility/STOP_REPORT.md',
    'artifacts/manifests/stage3_cortical_state_feasibility/FINALIZE_STOP_REPORT.md',
    'artifacts/manifests/stage3_cortical_state_feasibility/FINALIZE_EVIDENCE_STOP.json',
    'artifacts/manifests/stage3_cortical_state_feasibility/prediction_preserve_repair.ps1',
    'results/stage_3/current/prediction_validation/code_analyzer.json',
    'results/stage_3/current/prediction_validation/code_analyzer_repair.json',
    'results/stage_3/current/prediction_validation/code_analyzer_completion.json',
    'results/stage_3/current/prediction_validation/code_analyzer_prepublication.json'
)
$postgoDocs=@('README.md','AGENTS.md','MODEL_SPEC.md',
    'artifacts/manifests/stage3_cortical_state_feasibility/BIO_RESUME_REPORT.md',
    'artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_REPORT.md')
if($Mode -eq 'Inventory'){
    if(Test-Path -LiteralPath $postgoInventory){throw 'Reviewed inventory exists; do not silently replace classifications'}
    $postgoRows=@(foreach($postgoFile in $postgoBaseline){
        $postgoAction='KEEP'; $postgoReason='Protected foundation/infrastructure or reproducibility evidence'
        if($postgoFile.path -match 'stage_3|stage3_cortical|run_stage_3'){
            $postgoReason='Retain current science or earlier construction/audit provenance; potentially meaningful dependencies are not scratch'
        }
        if($postgoFile.path -match 'cache/(biological_revision|prediction_validation)/'){
            $postgoReason='Current raw controller/trial/audit evidence; includes reused preflight and network-1 preparation'
        }
        if($postgoFile.path -match 'cache/(gain_time|evidence_recovery)/'){
            $postgoReason='Retain ambiguous historical scientific evidence and reproduction support; not a current biological result'
        }
        if($postgoFile.path -match '^plots/stage_3/'){$postgoReason='One of seven protected current figure pairs'}
        if($postgoFile.path -in $postgoDocs){$postgoAction='DOCUMENTATION';$postgoReason='Current documentation consolidation; numerical content unchanged'}
        if($postgoFile.path -eq 'run_stage_3.m'){$postgoAction='RUNNER';$postgoReason='Remove retired fallback dispatch; preserve identical current saved-output figures/validate actions'}
        if($postgoFile.path -in $postgoRetire){
            $postgoAction='REMOVE';$postgoReason='Superseded stop or interim static receipt; substantive resolution in current reports and checkpoint 3268329'
        }
        if($postgoFile.path -eq 'run_stage_3_finalize.m'){
            $postgoReason='Duplicate current figures/validate entry point; run_stage_3 provides identical current actions; no executable callers'
        }
        if($postgoFile.path -match '^artifacts/manifests/stage3_cortical_state_feasibility/.*\.log$'){
            $postgoAction='REMOVE';$postgoReason='Closed temporary execution log; final numerical and validation evidence retained'
        }
        [pscustomobject]@{path=$postgoFile.path;bytes=$postgoFile.bytes;sha256=$postgoFile.sha256;tracked=$postgoFile.tracked;action=$postgoAction;reason=$postgoReason}
    })
    $postgoRows | Export-Csv -LiteralPath $postgoInventory -NoTypeInformation
    $postgoRows | Group-Object action | Select-Object Name,Count
    return
}
$postgoRows=Import-Csv -LiteralPath $postgoInventory
$postgoAudit=Get-Content -LiteralPath (Join-Path $postgoRoot 'results/stage_3/current/postgo_noise_diagnostic/independent_audit.json') -Raw | ConvertFrom-Json
if($postgoAudit.status -ne 'PASS'){throw 'Independent causal audit must pass before cleanup'}
if($Mode -eq 'Remove'){
    $postgoRemoved=@(foreach($postgoRow in ($postgoRows | Where-Object action -eq 'REMOVE')){
        $postgoTarget=(Resolve-Path -LiteralPath (Join-Path $postgoRoot $postgoRow.path)).Path
        if(-not $postgoTarget.StartsWith($postgoRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Deletion escaped repository'}
        if((Get-Item -LiteralPath $postgoTarget).PSIsContainer){throw 'Only reviewed individual files can be removed'}
        if((Get-FileHash -LiteralPath $postgoTarget).Hash -ne $postgoRow.sha256){throw "Changed removal target: $($postgoRow.path)"}
        Remove-Item -LiteralPath $postgoTarget
        if(Test-Path -LiteralPath $postgoTarget){throw "Removal failed: $postgoTarget"}
        $postgoRow
    })
    $postgoLog=Join-Path $PSScriptRoot 'postgo_production.log'
    if(Test-Path -LiteralPath $postgoLog){
        $postgoLog=(Resolve-Path -LiteralPath $postgoLog).Path
        if(-not $postgoLog.StartsWith($postgoRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Log deletion escaped repository'}
        $postgoLogInfo=Get-Item -LiteralPath $postgoLog
        if($postgoLogInfo.PSIsContainer){throw 'Expected a closed individual execution log'}
        $postgoLogRow=[pscustomobject]@{path=[IO.Path]::GetRelativePath($postgoRoot,$postgoLog).Replace('\','/');bytes=$postgoLogInfo.Length;sha256=(Get-FileHash -LiteralPath $postgoLog).Hash;tracked='False';action='REMOVE';reason='Closed current replay transcript; complete per-case identity and timing receipt retained in production_complete.json'}
        $postgoLogRow | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'POSTGO_NEW_LOG_CLASSIFICATION.csv') -NoTypeInformation
        Remove-Item -LiteralPath $postgoLog
        if(Test-Path -LiteralPath $postgoLog){throw 'Current closed log removal failed'}
        $postgoRemoved+=$postgoLogRow
    }
    $postgoRemoved | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'POSTGO_REMOVED.csv') -NoTypeInformation
    Write-Output "Removed $($postgoRemoved.Count) individually reviewed files; tracked originals remain recoverable at 3268329"
}else{
    foreach($postgoRow in $postgoRows){
        $postgoTarget=Join-Path $postgoRoot $postgoRow.path
        if($postgoRow.action -eq 'REMOVE'){
            if(Test-Path -LiteralPath $postgoTarget){throw "Retired file remains: $($postgoRow.path)"}
        }elseif($postgoRow.action -eq 'KEEP'){
            if((Get-FileHash -LiteralPath $postgoTarget).Hash -ne $postgoRow.sha256){throw "Protected file changed: $($postgoRow.path)"}
        }elseif(-not(Test-Path -LiteralPath $postgoTarget)){throw "Documentation missing: $($postgoRow.path)"}
    }
    $postgoReceipt=[ordered]@{status='PASS';baselineFiles=$postgoRows.Count;unchangedFiles=@($postgoRows|Where-Object action -eq 'KEEP').Count;documentedEdits=@($postgoRows|Where-Object action -eq 'DOCUMENTATION').Count;runnerOnlyEdits=@($postgoRows|Where-Object action -eq 'RUNNER').Count;removedFiles=@($postgoRows|Where-Object action -eq 'REMOVE').Count;checkedUTC=[DateTime]::UtcNow.ToString('o')}
    $postgoReceipt | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'POSTGO_PRESERVATION.json') -Encoding utf8
    $postgoReceipt
}
