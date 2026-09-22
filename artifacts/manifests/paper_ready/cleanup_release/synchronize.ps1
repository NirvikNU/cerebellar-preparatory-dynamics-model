param([Parameter(Mandatory=$true)][string]$ReleaseSha)
$ErrorActionPreference='Stop'
$releaseRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $releaseRoot
$expectedOld='70fff703f8fd3074bef62ca9954a03bef50e4d99'
function ReleaseGit([string[]]$GitArguments){
    $answer=@(& git @GitArguments)
    if($LASTEXITCODE -ne 0){throw "Git operation failed: $($GitArguments -join ' ')"}
    return $answer
}
if($ReleaseSha -notmatch '^[a-f0-9]{40}$'){throw 'Expected explicit full release SHA'}
if((ReleaseGit -GitArguments @('rev-parse','HEAD')) -ne $ReleaseSha){throw 'Unexpected HEAD'}
if((ReleaseGit -GitArguments @('rev-parse','HEAD^')) -ne $expectedOld){throw 'Expected exactly one release commit'}
if((ReleaseGit -GitArguments @('branch','--show-current')) -ne 'v3-romano-hennequin'){throw 'Wrong active branch'}
if((ReleaseGit -GitArguments @('rev-parse','--abbrev-ref','@{upstream}')) -ne 'origin/v3-romano-hennequin'){throw 'Wrong upstream'}
if((ReleaseGit -GitArguments @('log','-1','--format=%s')) -ne 'Finalize paper modelling prediction and stabilization diagnostics'){throw 'Wrong release message'}
if((ReleaseGit -GitArguments @('remote','get-url','origin')) -ne 'https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model.git'){throw 'Unexpected remote'}
if(@(ReleaseGit -GitArguments @('status','--porcelain=v1','--untracked-files=all')).Count){throw 'Worktree/index not clean before push'}
ReleaseGit -GitArguments @('fetch','origin') | Out-Host
$localMain=(ReleaseGit -GitArguments @('rev-parse','refs/heads/main')) -join ''
$trackingMain=(ReleaseGit -GitArguments @('rev-parse','refs/remotes/origin/main')) -join ''
$trackingV3=(ReleaseGit -GitArguments @('rev-parse','refs/remotes/origin/v3-romano-hennequin')) -join ''
$direct=@(ReleaseGit -GitArguments @('ls-remote','origin','refs/heads/main','refs/heads/v3-romano-hennequin'))
if($localMain -ne $expectedOld -or $trackingMain -ne $expectedOld -or $trackingV3 -ne $expectedOld -or $direct.Count -ne 2 -or @($direct | Where-Object {($_ -split '\s+')[0] -ne $expectedOld}).Count){throw 'Expected-old-SHA guard failed; stop without synchronization'}
ReleaseGit -GitArguments @('merge-base','--is-ancestor',$localMain,$ReleaseSha) | Out-Host
ReleaseGit -GitArguments @('push','origin','refs/heads/v3-romano-hennequin:refs/heads/v3-romano-hennequin') | Out-Host
# Recheck main after the v3 push, then use compare-and-swap for its local ref.
$mainDirect=@(ReleaseGit -GitArguments @('ls-remote','origin','refs/heads/main'))
if($mainDirect.Count -ne 1 -or ($mainDirect[0] -split '\s+')[0] -ne $expectedOld){throw 'Remote main changed after v3 push; stop'}
ReleaseGit -GitArguments @('merge-base','--is-ancestor','refs/heads/main',$ReleaseSha) | Out-Host
ReleaseGit -GitArguments @('update-ref','refs/heads/main',$ReleaseSha,$expectedOld) | Out-Host
ReleaseGit -GitArguments @('push','origin','refs/heads/main:refs/heads/main') | Out-Host
ReleaseGit -GitArguments @('fetch','origin') | Out-Host
$refs=@(ReleaseGit -GitArguments @('for-each-ref','--format=%(refname) %(objectname)','refs/heads/main','refs/heads/v3-romano-hennequin','refs/remotes/origin/main','refs/remotes/origin/v3-romano-hennequin'))
$remote=@(ReleaseGit -GitArguments @('ls-remote','origin','refs/heads/main','refs/heads/v3-romano-hennequin'))
$status=@(ReleaseGit -GitArguments @('status','--porcelain=v1','--untracked-files=all'))
$ignored=@(ReleaseGit -GitArguments @('ls-files','--others','--ignored','--exclude-standard'))
$unexpected=@($ignored | Where-Object {$_ -notmatch '^results/.*/cache/|^results/stage_1/|^third_party/kao_optimal_preparation/local_cache/'})
$locks=@(Get-ChildItem -LiteralPath .git -Force -Recurse -File -Filter '*.lock')
if($refs.Count -ne 4 -or @($refs | Where-Object {($_ -split ' ')[1] -ne $ReleaseSha}).Count -or $remote.Count -ne 2 -or @($remote | Where-Object {($_ -split '\s+')[0] -ne $ReleaseSha}).Count -or (ReleaseGit -GitArguments @('rev-parse','HEAD')) -ne $ReleaseSha){throw 'Final SHA equality failed'}
if($status.Count -or $unexpected.Count -or $locks.Count){throw 'Final status/cache/lock verification failed'}
$receipt=[ordered]@{task='PAPER-MODELLING-CLEANUP-RELEASE-01';status='PASS';releaseSha=$ReleaseSha;previousSha=$expectedOld;references=$refs;directRemote=$remote;head=$ReleaseSha;branch='v3-romano-hennequin';guardedMainFastForward=$true;cleanTrackedWorktree=$true;cleanIndex=$true;untrackedFiles=0;ignoredFiles=$ignored.Count;ignoredScope='Required raw/accepted local assets and pinned source/reference cache only';gitLocks=0;normalCommitCount=1;normalPushes=2;historyRewritten=$false;newScienceRun=$false;etaSelected=$false;verifiedUTC=[DateTime]::UtcNow.ToString('o')}
$receipt | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath .git/paper-modelling-cleanup-release.json
$receipt | ConvertTo-Json -Depth 6
