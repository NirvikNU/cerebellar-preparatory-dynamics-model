$ErrorActionPreference='Stop'
$resumeRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$allowed=@('AGENTS.md','README.md','MODEL_SPEC.md','run_stage_3.m','run_stage_3_finalize.m',
    'figures\stage_3\stage3_figures.m','figures\stage_3\stage3_gain_time_figure.m')
$names=@('result_1_preparation_and_movement','result_2_preparatory_geometry',
    'diagnostic_1_feasible_solution_map','diagnostic_2_component_removal')
foreach($name in $names){$allowed+=('plots\stage_3\png\'+$name+'.png');$allowed+=('plots\stage_3\fig\'+$name+'.fig')}
$rows=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'BIO_RESUME_BEFORE.csv')
$changed=@();$unchanged=0
foreach($row in $rows){
    $path=Join-Path $resumeRoot $row.path
    if(-not (Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing preserved file: $($row.path)"}
    $hash=(Get-FileHash -LiteralPath $path).Hash
    if($hash -eq $row.sha256){$unchanged++}else{
        if($row.path -notin $allowed){throw "Unapproved preserved-file change: $($row.path)"}
        $changed+=[pscustomobject]@{path=$row.path;before=$row.sha256;after=$hash}
    }
}
$protected=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'PROTECTED_BEFORE.csv')
foreach($r in $protected){if((Get-FileHash -LiteralPath (Join-Path $resumeRoot $r.relative_path)).Hash -ne $r.sha256){throw "Protected Stage1/2 changed: $($r.relative_path)"}}
$receipt=[pscustomobject]@{status='PASS';baselineFiles=$rows.Count;unchanged=$unchanged;authorizedChanges=$changed;
    protectedStage12Unchanged=$protected.Count;deletedBaselineFiles=0;utc=[DateTime]::UtcNow.ToString('o')}
$receipt | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'BIO_RESUME_PRESERVATION.json')
Write-Output "PASS: $unchanged unchanged baseline files; $($changed.Count) authorized changes; $($protected.Count) Stage1/2 protected; no baseline deletions"
