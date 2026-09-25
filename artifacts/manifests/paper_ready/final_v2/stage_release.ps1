param([switch]$ResumeStagedReview)
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
Set-Location -LiteralPath $repoRoot
$owners=@(Get-CimInstance Win32_Process -Filter "Name='pwsh.exe'" | Where-Object {
    $_.ProcessId -ne $PID -and $_.CommandLine -like '*& ./artifacts/manifests/paper_ready/final_v2/finish_inventory.ps1*'
})
if($owners.Count -gt 1){throw 'Multiple inventory owners'}
if($owners.Count -eq 1){Wait-Process -Id $owners[0].ProcessId}
foreach($name in @('CLEANUP','preservation_resume','visual_review','static_canvas_final','notion_publication','notion_preservation')){
    $r=Get-Content -LiteralPath (Join-Path $PSScriptRoot ($name+'.json')) -Raw | ConvertFrom-Json
    if($r.status -ne 'PASS'){throw "Release gate not passed: $name"}
}
if((git rev-parse HEAD) -ne '93e9d517d47b48579ef9d5bda6adacc44bf039d7'){throw 'HEAD changed'}
if((git branch --show-current) -ne 'v3-romano-hennequin'){throw 'Wrong branch'}
git diff --cached --quiet
if(($LASTEXITCODE -ne 0) -ne [bool]$ResumeStagedReview){throw 'Existing index/resume state mismatch'}
$scope=@('README.md','docs/paper_ready/CURRENT_REVIEW.md','docs/paper_ready/PAPER_CODE_INDEX.md')
foreach($base in @('analysis','figures','results','plots','docs','artifacts/manifests')){
    foreach($bundle in @('final_v2','noise_sensitivity')){$scope+=($base+'/paper_ready/'+$bundle)}
}
git add -- @scope
if($LASTEXITCODE){throw 'Staging failed'}
git diff --cached --check -- . `
    ':(exclude)artifacts/manifests/paper_ready/final_v2/grid.stderr.txt' `
    ':(exclude)artifacts/manifests/paper_ready/final_v2/preflight.stderr.txt' `
    ':(exclude)artifacts/manifests/paper_ready/final_v2/preflight2.stderr.txt' `
    ':(exclude)artifacts/manifests/paper_ready/noise_sensitivity/completion.stdout.txt' `
    ':(exclude)artifacts/manifests/paper_ready/noise_sensitivity/preflight.stderr.txt' `
    ':(exclude)artifacts/manifests/paper_ready/noise_sensitivity/preflight2.stdout.txt' `
    ':(exclude)artifacts/manifests/paper_ready/noise_sensitivity/simulation.stdout.txt' `
    ':(exclude)docs/paper_ready/final_v2/NOTION_CONTRACT.md'
if($LASTEXITCODE){throw 'Staged whitespace check failed'}
$names=@(git diff --cached --name-only)
if($LASTEXITCODE){throw 'Staged names failed'}
$unexpected=@($names | Where-Object {$_ -notmatch '^(analysis|figures|results|plots|docs|artifacts/manifests)/paper_ready/(final_v2|noise_sensitivity)/|^(README\.md|docs/paper_ready/(PAPER_CODE_INDEX|CURRENT_REVIEW)\.md)$'})
if($unexpected.Count){throw 'Unexpected staged path'}
if(@(git ls-files --others --exclude-standard).Count){throw 'Durable untracked content remains'}
git diff --quiet
if($LASTEXITCODE){throw 'Unstaged tracked content remains'}
$tree=git write-tree
if($LASTEXITCODE){throw 'Index tree failed'}
[ordered]@{status='NEEDS_REVIEW';parent='93e9d517d47b48579ef9d5bda6adacc44bf039d7';tree=$tree;files=$names.Count;scope=$scope} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath .git/paper-modelling-final-v2-staged.json
git diff --cached --stat
git diff --cached --numstat
Get-Content -LiteralPath .git/paper-modelling-final-v2-staged.json
