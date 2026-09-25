param([switch]$ResumeAfterClassificationStop)
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
Set-Location -LiteralPath $repoRoot
$inventoryPath=Join-Path $PSScriptRoot 'INVENTORY.csv'
$ledgerPath=Join-Path $PSScriptRoot 'DELETIONS.csv'
$receiptPath=Join-Path $PSScriptRoot 'CLEANUP.json'
foreach($p in @($inventoryPath,$receiptPath)){if(Test-Path -LiteralPath $p){throw 'Cleanup receipt already exists'}}
if((Test-Path -LiteralPath $ledgerPath) -ne [bool]$ResumeAfterClassificationStop){throw 'Deletion ledger/resume state mismatch'}
foreach($p in @('results/paper_ready/final_v2/audit.json','results/paper_ready/final_v2/output_audit.json','results/paper_ready/final_v2/control_tables.json','results/paper_ready/final_v2/dispersion_resolution.json','artifacts/manifests/paper_ready/final_v2/visual_review.json','artifacts/manifests/paper_ready/final_v2/preservation_after.json','artifacts/manifests/paper_ready/final_v2/preservation_resume.json','artifacts/manifests/paper_ready/final_v2/static_canvas_final.json','artifacts/manifests/paper_ready/final_v2/notion_publication.json')){
    $r=Get-Content -LiteralPath $p -Raw | ConvertFrom-Json
    if($r.status -ne 'PASS'){throw "Unpassed release gate: $p"}
}
$protected=@{}
Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'PROTECTED_BEFORE.csv') | ForEach-Object {$protected[$_.path]=$_.sha256}
$tracked=@{}; git ls-files | ForEach-Object {$tracked[$_]=$true}; if($LASTEXITCODE){throw 'Tracked inventory failed'}
$ignored=@{}; git ls-files --others --ignored --exclude-standard | ForEach-Object {$ignored[$_]=$true}; if($LASTEXITCODE){throw 'Ignored inventory failed'}
# All original files are preserved. Only new, closed, zero-byte v2 execution logs qualify.
$empty=@(Get-ChildItem -LiteralPath $PSScriptRoot -File -Force | Where-Object {$_.Length -eq 0 -and $_.Name -match '\.(stderr|stdout)\.txt$'})
$deletions=@()
if($ResumeAfterClassificationStop){
    $deletions=@(Import-Csv -LiteralPath $ledgerPath)
    foreach($row in $deletions){
        if($row.bytes -ne '0' -or $row.sha256 -ne 'E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855' -or (Test-Path -LiteralPath (Join-Path $repoRoot $row.path))){throw 'Existing deletion ledger verification failed'}
    }
    if($empty.Count){throw 'Unexpected additional empty logs; no repeat deletion on resume'}
}else{
$deletions=@(foreach($file in $empty){
    $resolved=(Resolve-Path -LiteralPath $file.FullName).Path
    if([IO.Path]::GetDirectoryName($resolved) -ne $PSScriptRoot){throw 'Deletion target escaped the explicit final-v2 manifest directory'}
    $rel=[IO.Path]::GetRelativePath($repoRoot,$resolved).Replace('\','/')
    if($protected.ContainsKey($rel) -or $tracked.ContainsKey($rel)){throw 'Original or tracked file cannot be deleted'}
    if((Get-Item -LiteralPath $resolved).Length -ne 0){throw 'Log changed before deletion'}
    $hash=(Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash
    if($hash -ne 'E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855'){throw 'Empty-file hash mismatch'}
    Remove-Item -LiteralPath $resolved
    if(Test-Path -LiteralPath $resolved){throw 'Exact empty-log deletion failed'}
    [pscustomobject]@{path=$rel;bytes=0;sha256=$hash;action='deleted';reason='Closed new zero-byte execution log; contains no unique content';retainedEvidence='Phase-specific JSON audit receipts and nonempty logs in this directory'}
})
if($deletions.Count){$deletions | Export-Csv -LiteralPath $ledgerPath -NoTypeInformation}
else{[IO.File]::WriteAllText($ledgerPath,'path,bytes,sha256,action,reason,retainedEvidence'+[Environment]::NewLine)}
}
# git ls-files omits nested-repository administration even under an ignored
# parent. Verify the actual rule; never treat that omission as durable science.
$pinnedScope='third_party/kao_optimal_preparation/local_cache/'
git check-ignore --no-index -q -- ($pinnedScope+'kao_optimal_preparation/.git/config')
if($LASTEXITCODE){throw 'Pinned source administration ignore rule not verified'}
$allowedDocs=@('README.md','docs/paper_ready/PAPER_CODE_INDEX.md','docs/paper_ready/CURRENT_REVIEW.md')
$files=@(Get-ChildItem -LiteralPath $repoRoot -File -Force -Recurse | Where-Object {$_.FullName -notlike "$repoRoot\.git\*"} | Sort-Object FullName)
$rows=@(foreach($file in $files){
    $rel=[IO.Path]::GetRelativePath($repoRoot,$file.FullName).Replace('\','/')
    $state=if($tracked.ContainsKey($rel)){'tracked'}elseif($ignored.ContainsKey($rel) -or $rel.StartsWith($pinnedScope)){'ignored'}else{'untracked'}
    $old=$protected.ContainsKey($rel)
    $hash=if($old -and $rel -notin $allowedDocs){$protected[$rel]}else{(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash}
    if($state -eq 'ignored'){
        if($rel -notmatch '^results/.*/cache/|^results/stage_1/|^third_party/kao_optimal_preparation/local_cache/'){throw "Unexpected ignored file: $rel"}
        $class='Required non-versioned raw/accepted scientific asset or pinned source input'; $action='retain ignored; never stage'
    }else{
        $class=if($old){'Preserved durable science/provenance/infrastructure'}else{'Final-v2 or noise-sensitivity durable release artifact/documentation'}
        $action='retain for normal reviewed release'
        if($file.Length -gt 95MB){throw "Oversize durable Git candidate: $rel"}
        if($state -eq 'untracked' -and $rel -notmatch '^(analysis|figures|results|plots|docs|artifacts/manifests)/paper_ready/(final_v2|noise_sensitivity)/|^docs/paper_ready/PAPER_CODE_INDEX\.md$'){throw "Unrelated durable untracked file: $rel"}
    }
    [pscustomobject]@{path=$rel;bytes=$file.Length;sha256=$hash;attributes=[string]$file.Attributes;gitState=$state;preexisting=$old;classification=$class;action=$action}
})
$rows | Export-Csv -LiteralPath $inventoryPath -NoTypeInformation
[ordered]@{status='PASS';task='PAPER-MODELLING-FINAL-FIGURES-V2-01';inventoryFiles=$rows.Count;ignoredFiles=@($rows|Where-Object gitState -eq ignored).Count;durableFiles=@($rows|Where-Object gitState -ne ignored).Count;deletedEmptyNewLogs=$deletions.Count;deletedBytes=0;originalFilesDeleted=0;scientificAssetsDeleted=0;hashScope='Original hashes reverified by preservation_after; new files hashed in this inventory';selfExclusions='Inventory and cleanup receipt are emitted after enumeration; Git metadata excluded';utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $receiptPath
Get-Content -LiteralPath $receiptPath
