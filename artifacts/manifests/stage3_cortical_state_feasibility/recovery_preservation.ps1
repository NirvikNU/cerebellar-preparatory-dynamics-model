param([ValidateSet('before','after')][string]$Phase = 'before')
$ErrorActionPreference = 'Stop'
$s3rRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$s3rPrior = Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'FINALIZE_INPUTS_AFTER.csv')
$s3rOutput = Join-Path $PSScriptRoot ("RECOVERY_INPUTS_" + $Phase.ToUpperInvariant() + '.csv')
if (Test-Path -LiteralPath $s3rOutput) { throw 'Refuse to overwrite recovery manifest.' }
$s3rRows = foreach ($s3rRow in $s3rPrior) {
    $s3rFile = Get-Item -LiteralPath (Join-Path $s3rRoot $s3rRow.relative_path)
    [pscustomobject]@{relative_path=$s3rRow.relative_path; bytes=$s3rFile.Length; sha256=(Get-FileHash -LiteralPath $s3rFile.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}
}
$s3rRows | Export-Csv -LiteralPath $s3rOutput -NoTypeInformation -Encoding utf8
$s3rAllowed = @('README.md','figures\stage_3\stage3_figures.m','plots\stage_3\fig\result_2_preparatory_geometry.fig','plots\stage_3\png\result_2_preparatory_geometry.png')
$s3rChanges = @(Compare-Object $s3rPrior $s3rRows -Property relative_path,bytes,sha256)
$s3rUnexpected = @($s3rChanges | Where-Object { $Phase -eq 'before' -or $_.relative_path -notin $s3rAllowed })
if ($s3rUnexpected.Count) { $s3rUnexpected | Format-Table; throw 'Preservation mismatch.' }
[pscustomobject]@{phase=$Phase;status='PASS';files=$s3rRows.Count;bytes=($s3rRows|Measure-Object bytes -Sum).Sum;permittedChangedPaths=@($s3rChanges.relative_path|Sort-Object -Unique);unexpectedChanges=0;utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json
