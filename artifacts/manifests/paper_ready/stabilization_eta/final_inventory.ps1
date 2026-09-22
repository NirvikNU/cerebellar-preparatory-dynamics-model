$ErrorActionPreference = 'Stop'
$taskRoot = 'E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $taskRoot
$taskManifest = Join-Path $taskRoot 'artifacts/manifests/paper_ready/stabilization_eta'
$taskInventoryPath = Join-Path $taskManifest 'OUTPUT_INVENTORY.csv'
$taskReceiptPath = Join-Path $taskManifest 'OUTPUT_INVENTORY.json'
$taskGitPath = Join-Path $taskManifest 'FINAL_GIT.json'
foreach ($taskPath in @($taskInventoryPath,$taskReceiptPath,$taskGitPath)) {
    if (Test-Path -LiteralPath $taskPath) { throw "Refuse to overwrite completed receipt: $taskPath" }
}
$taskAudit = Get-Content -LiteralPath 'results/paper_ready/stabilization_eta/audit.json' -Raw | ConvertFrom-Json
$taskFigures = Get-Content -LiteralPath (Join-Path $taskManifest 'FIGURES.json') -Raw | ConvertFrom-Json
if ($taskAudit.status -ne 'PASS' -or $taskFigures.status -ne 'PASS') { throw 'Validation not complete' }
$taskRoots = @('analysis/paper_ready/stabilization_eta','figures/paper_ready/stabilization_eta',
    'docs/paper_ready/stabilization_eta','artifacts/manifests/paper_ready/stabilization_eta',
    'results/paper_ready/stabilization_eta','results/paper_ready/cache/stabilization_eta',
    'plots/paper_ready/stabilization_eta')
$taskRows = foreach ($taskRelativeRoot in $taskRoots) {
    $taskResolved = (Resolve-Path -LiteralPath (Join-Path $taskRoot $taskRelativeRoot)).Path
    if (-not $taskResolved.StartsWith($taskRoot + '\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Inventory outside task root' }
    foreach ($taskFile in Get-ChildItem -LiteralPath $taskResolved -Force -File -Recurse) {
        [pscustomobject]@{
            path = [IO.Path]::GetRelativePath($taskRoot,$taskFile.FullName).Replace('\','/')
            bytes = $taskFile.Length
            sha256 = (Get-FileHash -LiteralPath $taskFile.FullName -Algorithm SHA256).Hash
            attributes = [string]$taskFile.Attributes
        }
    }
}
$taskRows | Sort-Object path | Export-Csv -LiteralPath $taskInventoryPath -NoTypeInformation
[ordered]@{
    status='PASS'; scope='Stabilization-eta roots only; prior passed preservation audit was not repeated'
    files=@($taskRows).Count; bytes=($taskRows | Measure-Object bytes -Sum).Sum
    excludedSelfReceipts=@('OUTPUT_INVENTORY.csv','OUTPUT_INVENTORY.json','FINAL_GIT.json')
    completedUTC=[DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $taskReceiptPath
$taskHead = (& git rev-parse HEAD).Trim()
$taskBranch = (& git branch --show-current).Trim()
if ($taskHead -ne '70fff703f8fd3074bef62ca9954a03bef50e4d99' -or $taskBranch -ne 'v3-romano-hennequin') { throw 'Unexpected Git checkpoint' }
& git diff --quiet
if ($LASTEXITCODE -ne 0) { throw 'Unexpected tracked worktree change' }
& git diff --cached --quiet
if ($LASTEXITCODE -ne 0) { throw 'Unexpected index change' }
$taskTrackedRaw = @(& git ls-files 'results/paper_ready/cache/stabilization_eta/')
if ($taskTrackedRaw.Count -ne 0) { throw 'Raw diagnostic cache unexpectedly tracked' }
$taskStatus = @(& git status --short --untracked-files=normal)
[ordered]@{
    head=$taskHead; branch=$taskBranch; trackedDiffEmpty=$true; indexDiffEmpty=$true
    status=$taskStatus; rawCacheTracked=$false; staged=$false; committed=$false; pushed=$false
    preservationEvidenceReused='RESUME_INVENTORY.json / RESUME_INPUTS.csv; no old-artifact writer called'
    scientificParametersRetuned=$false; rrrRun=$false; etaSelected=$false
    checkedUTC=[DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $taskGitPath
Get-Content -LiteralPath $taskReceiptPath,$taskGitPath
