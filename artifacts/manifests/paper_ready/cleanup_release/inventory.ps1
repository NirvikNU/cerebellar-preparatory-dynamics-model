$ErrorActionPreference = 'Stop'
$releaseRoot = 'E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $releaseRoot
$releaseOut = $PSScriptRoot
$receipt = Join-Path $releaseOut 'PRESERVATION_BEFORE.json'
if (Test-Path -LiteralPath $receipt) { throw 'Do not repeat completed preservation inventory' }
$known = @{}
foreach ($manifest in @('artifacts/manifests/paper_ready/stabilization_eta/RESUME_INPUTS.csv','artifacts/manifests/paper_ready/stabilization_eta/OUTPUT_INVENTORY.csv')) {
    foreach ($row in (Import-Csv -LiteralPath $manifest)) {
        if ($known.ContainsKey($row.path) -and $known[$row.path] -ne $row.sha256) { throw "Conflicting historical hash: $($row.path)" }
        $known[$row.path] = $row.sha256
    }
}
$all = @(Get-ChildItem -LiteralPath $releaseRoot -Recurse -Force -File | Where-Object {
    $_.FullName -notlike "$releaseRoot\.git\*" -and $_.FullName -notlike "$releaseOut\*"
} | Sort-Object FullName)
$rows = @(foreach ($file in $all) {
    $relative = [IO.Path]::GetRelativePath($releaseRoot,$file.FullName).Replace('\','/')
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    if ($known.ContainsKey($relative)) {
        if ($hash -ne $known[$relative]) { throw "Protected hash mismatch: $relative" }
        $known.Remove($relative)
    }
    [pscustomobject]@{path=$relative;bytes=$file.Length;sha256=$hash;attributes=[string]$file.Attributes}
})
if ($known.Count) { throw "Missing protected files: $($known.Keys -join ', ')" }
$rows | Export-Csv -LiteralPath (Join-Path $releaseOut 'ALL_FILES_BEFORE.csv') -NoTypeInformation
$taskRows = @($rows | Where-Object { $_.path -match '(^|/)(prediction|stabilization_eta)/' })
$classes = @(foreach ($row in $taskRows) {
    $category = switch -Regex ($row.path) {
        '^results/paper_ready/cache/' { 6; break }
        '^(analysis|figures)/' { 1; break }
        '^results/' { 2; break }
        '^docs/' { 3; break }
        '^plots/' { 4; break }
        '^artifacts/' { 5; break }
        default { throw "Unclassified: $($row.path)" }
    }
    [pscustomobject]@{path=$row.path;bytes=$row.bytes;sha256=$row.sha256;category=$category;action=$(if($category -eq 6){'retain ignored/local'}else{'retain durable; review packaging'});reason='Scientific output, source, reproducibility or distinct audit provenance; no demonstrated disposable duplicate'}
})
$classes | Export-Csv -LiteralPath (Join-Path $releaseOut 'CLEANUP_INVENTORY.csv') -NoTypeInformation
$ignored = @(git ls-files --others --ignored --exclude-standard)
if ($LASTEXITCODE) { throw 'Ignored inventory failed' }
$ignored | Set-Content -LiteralPath (Join-Path $releaseOut 'IGNORED_BEFORE.txt')
$untracked = @(git ls-files --others --exclude-standard)
$untracked | Set-Content -LiteralPath (Join-Path $releaseOut 'UNTRACKED_BEFORE.txt')
$duplicates = @($classes | Group-Object sha256 | Where-Object Count -gt 1 | ForEach-Object {
    [pscustomobject]@{sha256=$_.Name;paths=($_.Group.path -join ';');decision='Retain distinct provenance pending content review'}
})
$duplicates | Export-Csv -LiteralPath (Join-Path $releaseOut 'DUPLICATE_REVIEW.csv') -NoTypeInformation
[ordered]@{status='PASS';task='PAPER-MODELLING-CLEANUP-RELEASE-01';priorProtectedManifestRows=2295;allFiles=$rows.Count;allBytes=($rows | Measure-Object bytes -Sum).Sum;taskFiles=$classes.Count;taskBytes=($classes | Measure-Object bytes -Sum).Sum;categories=@($classes | Group-Object category | ForEach-Object { @{category=$_.Name;files=$_.Count;bytes=($_.Group | Measure-Object bytes -Sum).Sum} });checkedUTC=[DateTime]::UtcNow.ToString('o');noScientificComputation=$true} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $receipt
Get-Content -LiteralPath $receipt
