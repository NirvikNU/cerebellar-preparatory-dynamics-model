param([ValidateSet('before','after')][string]$Phase='before')
$ErrorActionPreference='Stop'
$bioRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$before=Join-Path $PSScriptRoot 'BIO_INPUTS_BEFORE.csv'
if ($Phase -eq 'before') {
    if(Test-Path -LiteralPath $before){throw 'Baseline already exists'}
    $rows=Get-ChildItem -LiteralPath $bioRoot -Recurse -Force -File | Where-Object {
        -not $_.FullName.StartsWith(($bioRoot+'\.git\'),[StringComparison]::OrdinalIgnoreCase) -and
        -not $_.FullName.StartsWith(($bioRoot+'\third_party\'),[StringComparison]::OrdinalIgnoreCase)
    } | ForEach-Object {[pscustomobject]@{path=$_.FullName.Substring($bioRoot.Length+1);bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}}
    $rows | Export-Csv -LiteralPath $before -NoTypeInformation
    Write-Output "Preservation baseline: $($rows.Count) files"
} else {
    $rows=Import-Csv -LiteralPath $before
    foreach($row in $rows){if((Get-FileHash -LiteralPath (Join-Path $bioRoot $row.path)).Hash -ne $row.sha256){throw "Preserved file changed: $($row.path)"}}
    $protected=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'PROTECTED_BEFORE.csv')
    foreach($row in $protected){if((Get-FileHash -LiteralPath (Join-Path $bioRoot $row.relative_path)).Hash -ne $row.sha256){throw "Stage1/2 changed: $($row.relative_path)"}}
    $out=[pscustomobject]@{status='PASS';baselineFilesUnchanged=$rows.Count;protectedStage12Unchanged=$protected.Count;utc=[DateTime]::UtcNow.ToString('o')}
    $out | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'BIO_PRESERVATION.json')
    $out | ConvertTo-Json
}
