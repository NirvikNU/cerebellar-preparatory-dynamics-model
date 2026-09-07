param()
$ErrorActionPreference = 'Stop'
$s3fRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$s3fOld = Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'PROTECTED_BEFORE.csv')
$s3fPaths = [System.Collections.Generic.List[string]]::new()
foreach ($s3fRow in $s3fOld) { $s3fPaths.Add($s3fRow.relative_path) }
$s3fGroups = @('results/stage_3/current','src/stage_3','analysis/stage_3','figures/stage_3','plots/stage_3')
foreach ($s3fGroup in $s3fGroups) {
    Get-ChildItem -LiteralPath (Join-Path $s3fRoot $s3fGroup) -Recurse -File -Force |
        Where-Object { $_.Name -ine 'desktop.ini' } |
        ForEach-Object { $s3fPaths.Add([IO.Path]::GetRelativePath($s3fRoot,$_.FullName)) }
}
foreach ($s3fName in @('.gitignore','AGENTS.md','README.md','MODEL_SPEC.md','run_stage_3.m','config/stage_3_config.m')) {
    $s3fPaths.Add($s3fName)
}
Get-ChildItem -LiteralPath $PSScriptRoot -File -Force |
    Where-Object { $_.Name -ine 'desktop.ini' -and $_.Name -notlike 'FINALIZE*' -and $_.Name -ne 'finalize_preservation_check.ps1' } |
    ForEach-Object { $s3fPaths.Add([IO.Path]::GetRelativePath($s3fRoot,$_.FullName)) }
$s3fUnique = @($s3fPaths | ForEach-Object { $_.Replace('/', '\') } | Sort-Object -Unique)
$s3fBeforePath = Join-Path $PSScriptRoot 'FINALIZE_INPUTS_BEFORE.csv'
$s3fAfterPath = Join-Path $PSScriptRoot 'FINALIZE_INPUTS_AFTER.csv'
$s3fReceiptPath = Join-Path $PSScriptRoot 'FINALIZE_PRESERVATION.json'
foreach ($s3fOutput in @($s3fBeforePath,$s3fAfterPath,$s3fReceiptPath)) {
    if (Test-Path -LiteralPath $s3fOutput) { throw "Refuse to overwrite receipt: $s3fOutput" }
}
function Get-S3fManifest {
    foreach ($s3fRelative in $s3fUnique) {
        $s3fAbsolute = Join-Path $s3fRoot $s3fRelative
        $s3fInfo = Get-Item -LiteralPath $s3fAbsolute
        [pscustomobject]@{
            relative_path = $s3fRelative
            bytes = $s3fInfo.Length
            sha256 = (Get-FileHash -LiteralPath $s3fAbsolute -Algorithm SHA256).Hash.ToLowerInvariant()
        }
    }
}
$s3fStarted = [DateTime]::UtcNow.ToString('o')
$s3fBefore = @(Get-S3fManifest)
$s3fBefore | Export-Csv -LiteralPath $s3fBeforePath -NoTypeInformation -Encoding utf8
foreach ($s3fPrior in $s3fOld) {
    $s3fActual = $s3fBefore | Where-Object relative_path -eq $s3fPrior.relative_path
    if ($s3fActual.sha256 -ne $s3fPrior.sha256) { throw "Protected baseline mismatch: $($s3fPrior.relative_path)" }
}
$s3fAfter = @(Get-S3fManifest)
$s3fAfter | Export-Csv -LiteralPath $s3fAfterPath -NoTypeInformation -Encoding utf8
$s3fChanged = @(Compare-Object $s3fBefore $s3fAfter -Property relative_path,bytes,sha256)
if ($s3fChanged.Count -ne 0) { throw 'Before/after preservation mismatch.' }
$s3fReceipt = [pscustomobject]@{
    task = 'STAGE3-FINALIZE-01'
    status = 'PASS'
    startedUTC = $s3fStarted
    completedUTC = [DateTime]::UtcNow.ToString('o')
    protectedStage1Stage2 = $s3fOld.Count
    preservedFiles = $s3fBefore.Count
    preservedBytes = ($s3fBefore | Measure-Object -Property bytes -Sum).Sum
    mismatches = 0
    scientificInputsWritten = $false
    scope = 'Read-only baseline and before/after hashing; no final scientific acceptance implied'
}
$s3fReceipt | ConvertTo-Json | Set-Content -LiteralPath $s3fReceiptPath -Encoding utf8
$s3fReceipt | ConvertTo-Json
