$ErrorActionPreference='Stop'
$peRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$peExpected='70fff703f8fd3074bef62ca9954a03bef50e4d99'
[ordered]@{status='RUNNING';note='Read-only Git verification in progress; this receipt is included in the final untracked status.'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'FINAL_GIT.json')
function Invoke-PeGit([string[]]$Arguments){
    $peOutput=@(& git -C $peRoot @Arguments)
    if($LASTEXITCODE -ne 0){throw "Read-only Git verification failed: $Arguments"}
    return $peOutput
}
$peHead=(Invoke-PeGit -Arguments @('rev-parse','HEAD')) -join ''
$peBranch=(Invoke-PeGit -Arguments @('branch','--show-current')) -join ''
$peUpstream=(Invoke-PeGit -Arguments @('rev-parse','--abbrev-ref','@{upstream}')) -join ''
$peRefs=@(Invoke-PeGit -Arguments @('for-each-ref','--format=%(refname) %(objectname)','refs/heads/main','refs/heads/v3-romano-hennequin','refs/remotes/origin/main','refs/remotes/origin/v3-romano-hennequin'))
$peRemote=(Invoke-PeGit -Arguments @('remote','get-url','origin')) -join ''
if($peRemote -ne 'https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model.git'){throw 'Unexpected upstream URL'}
$peDirect=@(Invoke-PeGit -Arguments @('ls-remote','--heads','origin','refs/heads/main','refs/heads/v3-romano-hennequin'))
$peTracked=@(Invoke-PeGit -Arguments @('diff','--name-only'))
$peIndexed=@(Invoke-PeGit -Arguments @('diff','--cached','--name-only'))
$peStatus=@(Invoke-PeGit -Arguments @('status','--porcelain=v1','--untracked-files=all'))
$null=Invoke-PeGit -Arguments @('diff','--check')
$peLocks=@(Get-ChildItem -LiteralPath (Join-Path $peRoot '.git') -Force -File -Recurse | Where-Object {$_.Name -like '*.lock'} | ForEach-Object {$_.FullName})
if($peHead -ne $peExpected -or $peBranch -ne 'v3-romano-hennequin' -or $peUpstream -ne 'origin/v3-romano-hennequin'){throw 'HEAD, branch or upstream changed'}
if($peRefs.Count -ne 4 -or @($peRefs | Where-Object {($_ -split ' ')[-1] -ne $peExpected}).Count){throw 'Local/tracking references differ'}
if($peDirect.Count -ne 2 -or @($peDirect | Where-Object {($_ -split '\s+')[0] -ne $peExpected}).Count){throw 'Direct remote differs'}
if($peTracked.Count -or $peIndexed.Count -or $peLocks.Count){throw 'Tracked change, indexed change or Git lock found'}
$peAllowed='^\?\? (analysis/paper_ready/prediction/|figures/paper_ready/prediction/|docs/paper_ready/prediction/|results/paper_ready/prediction/|plots/paper_ready/prediction/|artifacts/manifests/paper_ready/prediction/)'
if(@($peStatus | Where-Object {$_ -notmatch $peAllowed}).Count){throw 'Unexpected untracked path'}
[ordered]@{status='PASS';head=$peHead;branch=$peBranch;upstream=$peUpstream;remote=$peRemote;references=$peRefs;directRemote=$peDirect;trackedChanges=$peTracked;indexedChanges=$peIndexed;untrackedStatus=$peStatus;locks=$peLocks;worktreeClean=$false;trackedWorktreeClean=$true;indexClean=$true;staged=$false;commitCreated=$false;pushPerformed=$false;note='New prediction review artifacts remain untracked; all original files and Git references unchanged.'} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'FINAL_GIT.json')
"PASS: unchanged local/tracking/remote checkpoint; $($peStatus.Count) new untracked review files; no staging, commit or push"
