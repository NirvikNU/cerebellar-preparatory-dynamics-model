$ErrorActionPreference='Stop'
$repoRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $repoRoot
$receiptRoot=Join-Path $repoRoot 'artifacts/manifests/paper_ready/noise_sensitivity'
$path=Join-Path $receiptRoot 'FINAL_GIT.json'
if(Test-Path -LiteralPath $path){throw 'Final Git receipt already exists'}
$expected='93e9d517d47b48579ef9d5bda6adacc44bf039d7'
$head=(git rev-parse HEAD).Trim()
$branch=(git branch --show-current).Trim()
$upstream=(git rev-parse --abbrev-ref '@{upstream}').Trim()
$tracking=(git rev-parse '@{upstream}').Trim()
$remote=@(git ls-remote origin refs/heads/v3-romano-hennequin refs/heads/main)
if($LASTEXITCODE -ne 0 -or $head -ne $expected -or $tracking -ne $expected -or $branch -ne 'v3-romano-hennequin' -or $upstream -ne 'origin/v3-romano-hennequin'){throw 'Unexpected final Git state'}
if($remote.Count -ne 2 -or @($remote | Where-Object {($_ -split '\s+')[0] -ne $expected}).Count){throw 'Direct remote changed'}
git diff --exit-code
if($LASTEXITCODE -ne 0){throw 'Existing tracked files changed'}
git diff --cached --exit-code
if($LASTEXITCODE -ne 0){throw 'Index changed'}
$untracked=@(git ls-files --others --exclude-standard)
if(@($untracked | Where-Object {$_ -notmatch 'paper_ready/noise_sensitivity/'}).Count){throw 'Unrelated new files detected'}
$protected=Get-Content (Join-Path $receiptRoot 'preservation_after.json') -Raw | ConvertFrom-Json
if($protected.status -ne 'PASS'){throw 'No passed preservation receipt'}
$folders=@('analysis/paper_ready/noise_sensitivity','figures/paper_ready/noise_sensitivity','results/paper_ready/noise_sensitivity','results/paper_ready/cache/noise_sensitivity','plots/paper_ready/noise_sensitivity','docs/paper_ready/noise_sensitivity','artifacts/manifests/paper_ready/noise_sensitivity')
$inventory=foreach($folder in $folders){
    Get-ChildItem -LiteralPath (Join-Path $repoRoot $folder) -File -Recurse -Force | ForEach-Object {
        [pscustomobject]@{path=$_.FullName.Substring($repoRoot.Length+1).Replace('\','/');bytes=$_.Length;rawLocalOnly=$folder -eq 'results/paper_ready/cache/noise_sensitivity'}
    }
}
$inventory | Export-Csv -LiteralPath (Join-Path $receiptRoot 'TASK_INVENTORY.csv') -NoTypeInformation
[pscustomobject]@{status='PASS';utc=[DateTime]::UtcNow.ToString('o');head=$head;branch=$branch;upstream=$upstream;tracking=$tracking;directRemote=$remote;trackedDiff=@(git diff --stat);indexDiff=@(git diff --cached --stat);untracked=$untracked;taskFiles=$inventory.Count;taskBytes=($inventory|Measure-Object bytes -Sum).Sum;protectedFiles=$protected.files;committed=$false;pushed=$false;staged=$false;deleted=$false} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $path
Get-Content -LiteralPath $path
