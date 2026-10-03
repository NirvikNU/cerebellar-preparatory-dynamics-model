# Prepare only this display revision. Commit/push are separate reviewed steps.
$ErrorActionPreference='Stop'
$taskRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $taskRoot
$taskOld='54c965d8083dd51b30b4b67894d2a5ec6a62e439'
if((& git branch --show-current).Trim() -ne 'main'){throw 'Not on main'}
if((& git rev-parse --abbrev-ref '@{upstream}').Trim() -ne 'origin/main'){throw 'Unexpected upstream'}
if((& git remote get-url origin).Trim() -ne 'https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model.git'){throw 'Unexpected remote'}
foreach($taskRef in @('HEAD','main','origin/main')){if((& git rev-parse $taskRef).Trim() -ne $taskOld){throw 'Unexpected logical ref'}}
$taskRemote=@(& git ls-remote --exit-code origin refs/heads/main)
if($LASTEXITCODE -ne 0 -or $taskRemote.Count -ne 1 -or $taskRemote[0].Split("`t")[0] -ne $taskOld){throw 'Remote advanced or verification failed'}
if(@(& git diff --cached --name-only).Count -ne 0){throw 'Pre-existing staged changes'}
$taskNavigation='docs/paper_ready/final_v3/CURRENT_PANEL_INDEX.md'
if(@(Compare-Object @($taskNavigation) @(& git diff --name-only)).Count){throw 'Unexpected tracked change'}
$taskAnalysis='analysis/paper_ready/final_v3/fig6fgh_success10'
$taskDocs='docs/paper_ready/final_v3/fig6fgh_success10'
$taskResults='results/paper_ready/final_v3/fig6fgh_success10'
$taskPlots='plots/paper_ready/final_v3/fig6fgh_success10'
$taskPaths=[Collections.Generic.List[string]]::new()
$taskPaths.Add($taskNavigation)
foreach($taskName in @('sp10_load.m','sp10_measure.m','sp10_choose_target.m','sp10_build.m','sp10_audit.m','sp10_render.m','sp10_figcheck.m','sp10_run.m','sp10_finish_display.m')){$taskPaths.Add("$taskAnalysis/$taskName")}
foreach($taskName in @('INSTRUCTIONS.md','PLAN.md','REPORT.md','LEGENDS.md','DEPENDENCIES.md','preserve.ps1','run.ps1','remove_title_drafts.ps1','checkpoint.ps1','preserved_before.json','preservation_after.json','code_analyzer_initial_indent_warning.json','code_analyzer.json','code_analyzer_final.json','notion_validation.json','temporary_deletions.json')){$taskPaths.Add("$taskDocs/$taskName")}
foreach($taskName in @('network_ranking.csv','all_intact_target_scores.csv','target_eligibility.csv','all_trial_rankings.csv','Fig6f_selected_trials.csv','Fig6gh_selected_trials.csv','Fig6h_all30_inset.csv','selection.json','validation.json','render_validation_final.json')){$taskPaths.Add("$taskResults/$taskName")}
foreach($taskPanel in @('f','g','h')){foreach($taskExt in @('fig','png')){$taskPaths.Add("$taskPlots/$taskExt/Fig6$taskPanel.$taskExt")}}
foreach($taskPath in $taskPaths){
    $taskItem=Get-Item -LiteralPath (Join-Path $taskRoot $taskPath)
    if($taskItem.Length -gt 10MB -or $taskPath -match '/cache/|\.mat$|stdout|stderr|local_title_drafts|NOTION_BEFORE|git_final'){throw "Disallowed candidate $taskPath"}
}
$taskManifest=Get-Content -LiteralPath "$taskDocs/preserved_before.json" -Raw|ConvertFrom-Json
$taskPrior=@($taskManifest.untracked|Where-Object {$_ -notmatch '/fig6fgh_success10/'})
$taskNow=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6fgh_success10/'})
if(@(Compare-Object ($taskPrior|Sort-Object) ($taskNow|Sort-Object)).Count){throw 'Pre-existing untracked inventory changed'}
$taskPreservation=Get-Content -LiteralPath "$taskDocs/preservation_after.json" -Raw|ConvertFrom-Json
if($taskPreservation.status -ne 'PASS' -or $taskPreservation.deletedDependencies -ne 0){throw 'Preservation not validated'}
& git add -- $taskPaths.ToArray()
if($LASTEXITCODE -ne 0){throw 'Staging failed'}
$taskStaged=@(& git diff --cached --name-only)
if(@(Compare-Object ($taskPaths.ToArray()|Sort-Object) ($taskStaged|Sort-Object)).Count){throw 'Staged scope mismatch'}
& git diff --cached --check
if($LASTEXITCODE -ne 0){throw 'Staged whitespace errors'}
[pscustomobject]@{files=$taskStaged.Count;bytes=($taskPaths|ForEach-Object{(Get-Item -LiteralPath $_).Length}|Measure-Object -Sum).Sum;priorUntrackedPreserved=$taskPrior.Count;status='Staged for review only'}|ConvertTo-Json
& git diff --cached --stat
