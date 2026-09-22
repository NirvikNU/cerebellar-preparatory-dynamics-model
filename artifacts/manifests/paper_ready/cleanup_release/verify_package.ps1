$ErrorActionPreference='Stop'
$releaseRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $releaseRoot
$before=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'ALL_FILES_BEFORE.csv')
$moves=@{}
foreach($row in (Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'RELOCATIONS.csv'))){$moves[$row.oldPath]=$row.newPath}
$deleted=@((Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'DELETIONS.csv')).path)
$allowedDocs=@('AGENTS.md','README.md','docs/paper_ready/prediction/README.md','docs/paper_ready/prediction/PLAN.md','docs/paper_ready/prediction/RESULTS.md','docs/paper_ready/stabilization_eta/BASELINE_REPORT.md','artifacts/manifests/paper_ready/prediction/AUDIT.md')
$rows=@(foreach($row in $before){
    $relative=$row.path
    if($relative -in $deleted){
        if([long]$row.bytes -ne 0 -or (Test-Path -LiteralPath $relative)){throw "Invalid deletion: $relative"}
        continue
    }
    if($moves.ContainsKey($relative)){$relative=$moves[$relative]}
    $file=Get-Item -LiteralPath (Join-Path $releaseRoot $relative)
    if($row.path -in $allowedDocs){
        [pscustomobject]@{original=$row.path;path=$relative;status='Navigation/cross-reference edit only; reviewed diff';sha256=(Get-FileHash -LiteralPath $file.FullName).Hash}
    }elseif($row.path -match '^results/.*/cache/|^results/stage_1/|^third_party/kao_optimal_preparation/local_cache/'){
        # Full hash verification completed before cleanup; no scientific writer ran.
        if($file.Length -ne [long]$row.bytes -or $file.LastWriteTimeUtc -gt [DateTime]'2026-09-22T22:00:00Z'){throw "Unexpected cache modification: $relative"}
        [pscustomobject]@{original=$row.path;path=$relative;status='Full pre-cleanup hash PASS; final size/write-time unchanged; no writer run';sha256=$row.sha256}
    }else{
        $hash=(Get-FileHash -LiteralPath $file.FullName).Hash
        if($hash -ne $row.sha256){throw "Unexpected durable/protected change: $relative"}
        [pscustomobject]@{original=$row.path;path=$relative;status='Final SHA256 unchanged';sha256=$hash}
    }
})
$rows | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'PRESERVATION_FINAL.csv') -NoTypeInformation
$ignored=@(git ls-files --others --ignored --exclude-standard)
if($LASTEXITCODE){throw 'Git ignored check failed'}
$unexpected=@($ignored | Where-Object {$_ -notmatch '^results/.*/cache/|^results/stage_1/|^third_party/kao_optimal_preparation/local_cache/'})
if($unexpected.Count){throw "Unexpected ignored files: $($unexpected -join ', ')"}
$ignored | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'IGNORED_FINAL.txt')
$new=@(git ls-files --others --exclude-standard)
$files=@(foreach($path in $new){$file=Get-Item -LiteralPath $path; [pscustomobject]@{path=$path;bytes=$file.Length}})
if(@($files | Where-Object bytes -ge 50MB).Count){throw 'Unexpected >=50 MiB release file'}
if(@($new | Where-Object {$_ -match '/cache/|\.asv$|\.autosave$|\.tmp$|\.log$'}).Count){throw 'Transient/cache file would be staged'}
$files | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'RELEASE_FILES.csv') -NoTypeInformation
$duplicates=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'DUPLICATE_REVIEW.csv')
[ordered]@{status='PASS';priorFiles=$before.Count;retained=$rows.Count;relocated=$moves.Count;zeroByteFilesDeleted=$deleted.Count;scientificChanges=0;rawPreservation='Full hash before cleanup, final size/write-time check; no scientific writer called';remainingIgnoredFiles=$ignored.Count;ignoredScope='Required Stage-1 local assets, Stage-2/3/paper raw caches and pinned source/reference cache only';newDurableFiles=$files.Count;newDurableBytes=($files|Measure-Object bytes -Sum).Sum;maxFileBytes=($files|Measure-Object bytes -Maximum).Maximum;duplicateGroups=@($duplicates).Count;reviewUTC=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'PRESERVATION_FINAL.json')
Get-Content -LiteralPath (Join-Path $PSScriptRoot 'PRESERVATION_FINAL.json')
