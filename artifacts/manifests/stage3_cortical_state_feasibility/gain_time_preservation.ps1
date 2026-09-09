param([ValidateSet('before','after')][string]$Phase='before')
$ErrorActionPreference='Stop'
$gainRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$gainBefore=Join-Path $PSScriptRoot 'GAIN_TIME_INPUTS_BEFORE.csv'
if ($Phase -eq 'before') {
    if (Test-Path -LiteralPath $gainBefore) { throw 'Do not overwrite baseline.' }
    $gainFiles=Get-ChildItem -LiteralPath $gainRoot -Recurse -Force -File | Where-Object { -not $_.FullName.StartsWith(($gainRoot+'\.git\'),[StringComparison]::OrdinalIgnoreCase) -and -not $_.FullName.StartsWith(($gainRoot+'\third_party\'),[StringComparison]::OrdinalIgnoreCase) }
    $gainRows=foreach($gainFile in $gainFiles) { [pscustomobject]@{path=$gainFile.FullName.Substring($gainRoot.Length+1);bytes=$gainFile.Length;sha256=(Get-FileHash -LiteralPath $gainFile.FullName -Algorithm SHA256).Hash} }
    $gainRows | Export-Csv -LiteralPath $gainBefore -NoTypeInformation
    Get-ChildItem -LiteralPath $gainRoot -Force | Select-Object Name,Mode,Length | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'GAIN_TIME_ROOT_BEFORE.csv') -NoTypeInformation
    $gainPrior=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'RECOVERY_INPUTS_AFTER.csv')
    foreach($gainOld in $gainPrior) { if ((Get-FileHash -LiteralPath (Join-Path $gainRoot $gainOld.relative_path)).Hash -ne $gainOld.sha256) { throw ('Relocation preservation mismatch: '+$gainOld.relative_path) } }
    [pscustomobject]@{phase=$Phase;files=$gainRows.Count;prior292Hashes='PASS';bytes=($gainRows|Measure-Object bytes -Sum).Sum;utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json
} else {
    $gainRows=Import-Csv -LiteralPath $gainBefore
    $gainChanges=foreach($gainRow in $gainRows) {
        $gainPath=Join-Path $gainRoot $gainRow.path
        if (-not (Test-Path -LiteralPath $gainPath)) { [pscustomobject]@{path=$gainRow.path;status='moved_or_removed'} }
        elseif ((Get-FileHash -LiteralPath $gainPath).Hash -ne $gainRow.sha256) { [pscustomobject]@{path=$gainRow.path;status='modified'} }
    }
    $gainChanges | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'GAIN_TIME_CHANGED_FROM_BASELINE.csv') -NoTypeInformation
    $gainProtected=$gainRows | Where-Object { $_.path -match '^(results\\|src\\|config\\stage_[123]|plots\\stage_[12]\\)' }
    foreach($gainRow in $gainProtected) { if ((Get-FileHash -LiteralPath (Join-Path $gainRoot $gainRow.path)).Hash -ne $gainRow.sha256) { throw ('Scientific preservation failed: '+$gainRow.path) } }
    $gainStage12=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'PROTECTED_BEFORE.csv')
    foreach($gainRow in $gainStage12) { if ((Get-FileHash -LiteralPath (Join-Path $gainRoot $gainRow.relative_path)).Hash -ne $gainRow.sha256) { throw ('Stage-1/2 protected file changed: '+$gainRow.relative_path) } }
    $gainAllowed=@('MODEL_SPEC.md','README.md','analysis\stage_3\stage3_audit_rendered.m','figures\stage_3\stage3_figures.m','plots\stage_3\fig\diagnostic_2_component_removal.fig','plots\stage_3\png\diagnostic_2_component_removal.png','artifacts\manifests\stage3_cortical_state_feasibility\gain_time_preservation.ps1')
    $gainOrganization=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'GAIN_TIME_ROOT_ORGANIZATION.csv')
    $gainAllowed+=@($gainOrganization | Where-Object { $_.action -ne 'retain' } | Select-Object -ExpandProperty before)
    foreach($gainChange in $gainChanges) { if ($gainChange.path -notin $gainAllowed) { throw ('Unexpected changed baseline file: '+$gainChange.path) } }
    $gainReceipt=[pscustomobject]@{status='PASS';phase=$Phase;baselineFiles=$gainRows.Count;scientificFilesUnchanged=$gainProtected.Count;stage12ProtectedUnchanged=$gainStage12.Count;unexpectedChanges=0;changes=@($gainChanges);utc=[DateTime]::UtcNow.ToString('o')}
    $gainReceipt | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'GAIN_TIME_PRESERVATION.json')
    $gainReceipt | ConvertTo-Json -Depth 4
}
