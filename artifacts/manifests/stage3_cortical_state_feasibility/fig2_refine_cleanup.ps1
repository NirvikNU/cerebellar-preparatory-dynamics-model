$ErrorActionPreference='Stop'
$refineRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$scope=Join-Path $refineRoot 'results\stage_3\current\cache\gain_time\refined'
$review=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'FIG2_REFINE_REVIEW.json') -Raw | ConvertFrom-Json
if ($review.status -ne 'PASS' -or $review.newNullK.Count -ne 0 -or $review.redundantNullFiles.Count -ne 10) { throw 'Duplicate audit not satisfied' }
$inventory=@()
foreach($entry in $review.redundantNullFiles) {
    $resolved=(Resolve-Path -LiteralPath $entry.path).Path
    if ((Split-Path -Parent $resolved) -ne $scope -or (Split-Path -Leaf $resolved) -notmatch '^null_n(0[1-9]|10)\.mat$') { throw 'Out-of-scope deletion target' }
    if ((Get-FileHash -LiteralPath $resolved).Hash -ne $entry.sha256) { throw 'Duplicate changed since validation' }
    if ((Get-FileHash -LiteralPath $entry.preservedSource).Hash -ne $entry.preservedSourceSHA256) { throw 'Preserved source changed' }
    $inventory+=[pscustomobject]@{path=$resolved;bytes=(Get-Item -LiteralPath $resolved).Length;sha256=$entry.sha256;reason='New refinement serialization duplicates every original null-evidence field; MATLAB isequal PASS; no new null K';preservedSource=$entry.preservedSource}
}
# All exact paths/hashes and retained source copies checked before any removal.
foreach($entry in $inventory) { Remove-Item -LiteralPath $entry.path }
foreach($entry in $inventory) { if (Test-Path -LiteralPath $entry.path) { throw 'Removal verification failed' } }
$receipt=[pscustomobject]@{status='PASS';rootItems=(Get-ChildItem -LiteralPath $refineRoot -Force).Count;removed=@($inventory);preservation='All original null evidence retained; no scientific information lost';utc=[DateTime]::UtcNow.ToString('o')}
$receipt | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'FIG2_REFINE_CLEANUP.json')
Write-Output "Removed $($inventory.Count) verified new duplicate serializations; preserved originals. Root remains $($receipt.rootItems) items."
