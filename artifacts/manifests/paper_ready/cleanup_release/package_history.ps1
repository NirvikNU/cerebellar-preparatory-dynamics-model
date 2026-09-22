$ErrorActionPreference = 'Stop'
$releaseRoot = 'E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $releaseRoot
$inventory = Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'ALL_FILES_BEFORE.csv')
$preservation = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'PRESERVATION_BEFORE.json') | ConvertFrom-Json
if ($preservation.status -ne 'PASS') { throw 'Preservation gate not passed' }
$movementFile = Join-Path $PSScriptRoot 'RELOCATIONS.csv'
if (Test-Path -LiteralPath $movementFile) { throw 'Do not repeat completed packaging' }
$moves = @(
    'docs/paper_ready/stabilization_eta/PREFLIGHT_STOP.md',
    'docs/paper_ready/stabilization_eta/RESUME_PLAN.md',
    'docs/paper_ready/stabilization_eta/NOTION_CONTRACT.md',
    'docs/paper_ready/prediction/PRIMARY_RESULTS.md',
    'docs/paper_ready/prediction/EXECUTION_RECOVERY.md'
)
$records = [Collections.Generic.List[object]]::new()
$deletions = [Collections.Generic.List[object]]::new()
$planned = @(foreach ($row in $inventory) {
    if ($row.path -in $moves -or $row.path -match '^artifacts/manifests/.*\.log$') {
        $emptyLog = $row.path -like '*.log' -and [long]$row.bytes -eq 0
        [pscustomobject]@{path=$row.path;bytes=$row.bytes;sha256=$row.sha256;category=$(if($emptyLog){7}elseif($row.path -like 'docs/*'){3}else{5});action=$(if($emptyLog){'delete verified empty closed log'}else{'copy; hash-verify; remove original path, retaining all bytes'});reason=$(if($emptyLog){'Zero-byte file contains no unique evidence'}else{'Consolidate dated historical execution provenance'})}
    }
})
$planned | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'PACKAGING_CLASSIFICATION.csv') -NoTypeInformation
foreach ($row in $inventory) {
    $destination = $null
    if ($row.path -in $moves) {
        $destination = $row.path -replace '/([^/]+)$','/history/$1'
    } elseif ($row.path -match '^artifacts/manifests/.*\.log$') {
        # Closed historical stdout; preserve nonempty evidence as durable text.
        if ([long]$row.bytes -gt 0) {
            $destination = 'artifacts/manifests/paper_ready/cleanup_release/history_logs/' + ($row.path -replace '^artifacts/manifests/','' -replace '\.log$','.txt')
        }
    } else { continue }
    $source = [IO.Path]::GetFullPath((Join-Path $releaseRoot $row.path))
    if (-not $source.StartsWith($releaseRoot+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Source escaped repository' }
    if ((Get-FileHash -LiteralPath $source).Hash -ne $row.sha256) { throw "Changed source: $source" }
    if ($destination) {
        $target = [IO.Path]::GetFullPath((Join-Path $releaseRoot $destination))
        if (-not $target.StartsWith($releaseRoot+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Destination escaped repository' }
        if (Test-Path -LiteralPath $target) { throw "Destination exists: $target" }
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -LiteralPath $source -Destination $target
        if ((Get-FileHash -LiteralPath $target).Hash -ne $row.sha256) { throw 'Copied history hash mismatch' }
        Remove-Item -LiteralPath $source
        $records.Add([pscustomobject]@{oldPath=$row.path;newPath=$destination;bytes=$row.bytes;sha256=$row.sha256;category=$(if($row.path -like 'docs/*'){3}else{5});reason='Historical execution/phase evidence preserved byte-for-byte; consolidated navigation'})
        $records | Export-Csv -LiteralPath $movementFile -NoTypeInformation
    } else {
        if ((Get-Item -LiteralPath $source).Length -ne 0) { throw 'Only verified empty logs may be deleted' }
        Remove-Item -LiteralPath $source
        $deletions.Add([pscustomobject]@{path=$row.path;bytes=0;sha256=$row.sha256;category=7;reason='Closed zero-byte stdout file contains no evidence';retainedSource='Historical completed numerical/figure/static audit receipts; no file content existed'})
        $deletions | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'DELETIONS.csv') -NoTypeInformation
    }
}
$records | Export-Csv -LiteralPath $movementFile -NoTypeInformation
$deletions | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'DELETIONS.csv') -NoTypeInformation
[ordered]@{status='PASS';relocated=$records.Count;deletedEmptyLogs=$deletions.Count;allRelocatedHashesMatch=$true;scientificFilesDeleted=0} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'PACKAGING.json')
Get-Content -LiteralPath (Join-Path $PSScriptRoot 'PACKAGING.json')
