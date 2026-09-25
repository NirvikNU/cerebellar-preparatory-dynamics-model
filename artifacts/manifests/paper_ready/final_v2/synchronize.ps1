param([Parameter(Mandatory=$true)][string]$ReleaseSha)
$ErrorActionPreference='Stop'
$releaseRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
Set-Location -LiteralPath $releaseRoot
$expectedOld='93e9d517d47b48579ef9d5bda6adacc44bf039d7'
function ReleaseGit([Parameter(ValueFromRemainingArguments=$true)][string[]]$GitArguments){
    $answer=@(& git @GitArguments)
    if($LASTEXITCODE -ne 0){throw "Git operation failed: $($GitArguments -join ' ')"}
    return $answer
}
if($ReleaseSha -notmatch '^[a-f0-9]{40}$'){throw 'Explicit full release SHA required'}
if((ReleaseGit @('rev-parse','HEAD')) -ne $ReleaseSha){throw 'Unexpected HEAD'}
$parents=((ReleaseGit @('rev-list','--parents','-n','1','HEAD')) -join '') -split ' '
if($parents.Count -ne 2 -or $parents[1] -ne $expectedOld){throw 'Expected exactly one normal release commit'}
if((ReleaseGit @('branch','--show-current')) -ne 'v3-romano-hennequin'){throw 'Wrong active branch'}
if((ReleaseGit @('rev-parse','--abbrev-ref','@{upstream}')) -ne 'origin/v3-romano-hennequin'){throw 'Wrong upstream'}
if((ReleaseGit @('log','-1','--format=%s')) -ne 'Finalize parsimonious paper modelling figures and code'){throw 'Wrong commit subject'}
$review=Get-Content -LiteralPath '.git/paper-modelling-final-v2-staged.json' -Raw | ConvertFrom-Json
if($review.status -ne 'PASS' -or $review.parent -ne $expectedOld -or (ReleaseGit @('rev-parse','HEAD^{tree}')) -ne $review.tree){throw 'Committed tree differs from the explicitly reviewed staged tree'}
if((ReleaseGit @('remote','get-url','origin')) -ne 'https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model.git'){throw 'Unexpected remote'}
if(@(ReleaseGit @('status','--porcelain=v1','--untracked-files=all')).Count){throw 'Worktree/index not clean'}
if(@(ReleaseGit @('worktree','list','--porcelain') | Where-Object {$_ -eq 'branch refs/heads/main'}).Count){throw 'Main is checked out in another worktree'}
$locks=@(Get-ChildItem -LiteralPath .git -Force -Recurse -File -Filter '*.lock')
if($locks.Count){throw 'Git lock present; no repair authorized'}
ReleaseGit @('fetch','origin') | Out-Host
$localMain=(ReleaseGit @('rev-parse','refs/heads/main')) -join ''
$trackingMain=(ReleaseGit @('rev-parse','refs/remotes/origin/main')) -join ''
$trackingV3=(ReleaseGit @('rev-parse','refs/remotes/origin/v3-romano-hennequin')) -join ''
$direct=@(ReleaseGit @('ls-remote','origin','refs/heads/main','refs/heads/v3-romano-hennequin'))
if($localMain -ne $expectedOld -or $trackingMain -ne $expectedOld -or $trackingV3 -ne $expectedOld -or $direct.Count -ne 2 -or @($direct | Where-Object {($_ -split '\s+')[0] -ne $expectedOld}).Count){throw 'Expected-old-SHA guard failed'}
ReleaseGit @('merge-base','--is-ancestor',$localMain,$ReleaseSha) | Out-Host
ReleaseGit @('push','origin','refs/heads/v3-romano-hennequin:refs/heads/v3-romano-hennequin') | Out-Host
$mainDirect=@(ReleaseGit @('ls-remote','origin','refs/heads/main'))
if($mainDirect.Count -ne 1 -or ($mainDirect[0] -split '\s+')[0] -ne $expectedOld){throw 'Remote main changed after v3 push'}
ReleaseGit @('merge-base','--is-ancestor','refs/heads/main',$ReleaseSha) | Out-Host
ReleaseGit @('update-ref','refs/heads/main',$ReleaseSha,$expectedOld) | Out-Host
ReleaseGit @('push','origin','refs/heads/main:refs/heads/main') | Out-Host
ReleaseGit @('fetch','origin') | Out-Host
$refs=@(ReleaseGit @('for-each-ref','--format=%(refname) %(objectname)','refs/heads/main','refs/heads/v3-romano-hennequin','refs/remotes/origin/main','refs/remotes/origin/v3-romano-hennequin'))
$remote=@(ReleaseGit @('ls-remote','origin','refs/heads/main','refs/heads/v3-romano-hennequin'))
$status=@(ReleaseGit @('status','--porcelain=v1','--untracked-files=all'))
$ignored=@(ReleaseGit @('ls-files','--others','--ignored','--exclude-standard'))
$unexpected=@($ignored | Where-Object {$_ -notmatch '^results/.*/cache/|^results/stage_1/|^third_party/kao_optimal_preparation/local_cache/'})
$locks=@(Get-ChildItem -LiteralPath .git -Force -Recurse -File -Filter '*.lock')
if($refs.Count -ne 4 -or @($refs | Where-Object {($_ -split ' ')[1] -ne $ReleaseSha}).Count -or $remote.Count -ne 2 -or @($remote | Where-Object {($_ -split '\s+')[0] -ne $ReleaseSha}).Count -or (ReleaseGit @('rev-parse','HEAD')) -ne $ReleaseSha){throw 'Final SHA equality failed'}
if($status.Count -or $unexpected.Count -or $locks.Count){throw 'Final status/cache/lock check failed'}
$receipt=[ordered]@{task='PAPER-MODELLING-FINAL-FIGURES-V2-01';status='PASS';releaseSha=$ReleaseSha;previousSha=$expectedOld;references=$refs;directRemote=$remote;head=$ReleaseSha;branch='v3-romano-hennequin';guardedMainFastForward=$true;cleanTrackedWorktree=$true;cleanIndex=$true;untrackedFiles=0;ignoredFiles=$ignored.Count;ignoredScope='Required raw/accepted local assets and pinned source/reference cache only';gitLocks=0;normalCommitCount=1;normalPushes=2;historyRewritten=$false;verifiedUTC=[DateTime]::UtcNow.ToString('o')}
$receipt | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath .git/paper-modelling-final-v2-release.json
$receipt | ConvertTo-Json -Depth 6
