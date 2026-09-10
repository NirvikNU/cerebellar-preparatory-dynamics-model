param([ValidateSet('before','after')][string]$Phase='before')
$ErrorActionPreference='Stop'
$refineRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$before=Join-Path $PSScriptRoot 'FIG2_REFINE_BEFORE.csv'
if ($Phase -eq 'before') {
    if (Test-Path -LiteralPath $before) { throw 'Do not overwrite preservation baseline' }
    $rows=Get-ChildItem -LiteralPath $refineRoot -Recurse -Force -File | Where-Object {
        -not $_.FullName.StartsWith(($refineRoot+'\.git\'),[StringComparison]::OrdinalIgnoreCase) -and
        -not $_.FullName.StartsWith(($refineRoot+'\third_party\'),[StringComparison]::OrdinalIgnoreCase)
    } | ForEach-Object { [pscustomobject]@{path=$_.FullName.Substring($refineRoot.Length+1);bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash} }
    $rows | Export-Csv -LiteralPath $before -NoTypeInformation
    Write-Output "Preserved $($rows.Count) files in baseline"
} else {
    $allowed=@('README.md','MODEL_SPEC.md','analysis\stage_3\run_stage3_gain_time.m','analysis\stage_3\stage3_gain_time_check_figure.m','analysis\stage_3\stage3_audit_rendered.m','figures\stage_3\stage3_gain_time_figure.m','plots\stage_3\fig\diagnostic_2_component_removal.fig','plots\stage_3\png\diagnostic_2_component_removal.png')
    $rows=Import-Csv -LiteralPath $before
    $changes=@(); $unchanged=0
    foreach($row in $rows) {
        $file=Join-Path $refineRoot $row.path
        if (-not (Test-Path -LiteralPath $file)) { throw "Missing preserved file: $file" }
        if ((Get-FileHash -LiteralPath $file).Hash -ne $row.sha256) {
            if ($row.path -notin $allowed) { throw "Unexpected change: $file" }
            $changes+=$row.path
        } else { $unchanged++ }
    }
    $protected=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'PROTECTED_BEFORE.csv')
    foreach($row in $protected) { if ((Get-FileHash -LiteralPath (Join-Path $refineRoot $row.relative_path)).Hash -ne $row.sha256) { throw "Stage1/2 change: $($row.relative_path)" } }
    $receipt=[pscustomobject]@{status='PASS';baselineFiles=$rows.Count;unchanged=$unchanged;allowedChanges=$changes;stage12ProtectedUnchanged=$protected.Count;removedFiles=0;utc=[DateTime]::UtcNow.ToString('o')}
    $receipt | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'FIG2_REFINE_PRESERVATION.json')
    $receipt | ConvertTo-Json -Depth 4
}
