# Bounded checkpoint preparation only. Review the staged diff before committing.
$ErrorActionPreference='Stop'
$repo09='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $repo09
$baseline09='aa63c7914fadf6f7c96c634617e797eac3772246'
foreach($ref09 in @('HEAD','main','origin/main')){if((& git rev-parse $ref09).Trim() -ne $baseline09){throw 'Unexpected reference; stop'}}
if(@(& git diff --name-only).Count -ne 0 -or @(& git diff --cached --name-only).Count -ne 0){throw 'Unexpected preexisting tracked diff/index'}
$a09='analysis/paper_ready/final_v3/fig6fgh_cleanup09'
$d09='docs/paper_ready/final_v3/fig6fgh_cleanup09'
$r09='results/paper_ready/final_v3/fig6fgh_cleanup09'
$p09='plots/paper_ready/final_v3/fig6fgh_cleanup09'
$paths09=[Collections.Generic.List[string]]::new()
foreach($n09 in @('mv09_load.m','mv09_build.m','mv09_render.m','mv09_validate.m','mv09_run.m')){$paths09.Add("$a09/$n09")}
$paths09.Add('analysis/paper_ready/prospective_variability/pv_figure_check.m')
$paths09.Add('docs/paper_ready/final_v3/CURRENT_PANEL_INDEX.md')
foreach($n09 in @('PLAN.md','REPORT.md','LEGENDS.md','DEPENDENCIES.md','IMPLEMENTATION_NOTES.md','INSTRUCTIONS.md','inventory.ps1','protect.ps1','run.ps1','cleanup.ps1','checkpoint.ps1','inventory_before.json','inventory_after.json','protected_hashes.json','cleanup_manifest.json','cleanup_executed.json','retained_metadata_validation.json','preservation_validation.json','notion_validation.json','code_analyzer_initial_r1.json','code_analyzer_smoke.json')){$paths09.Add("$d09/$n09")}
foreach($n09 in @('all_intact_target_RMS.csv','all_trial_rankings.csv','Fig6f_selected_trials.csv','Fig6gh_selected_trials.csv','Fig6h_all30_inset.csv','network_ranking.csv','selected_network_target_ranking.csv','selection.json','validation.json','smoke/validation.json')){$paths09.Add("$r09/$n09")}
foreach($panel09 in @('f','g','h')){foreach($ext09 in @('fig','png')){$paths09.Add("$p09/$ext09/Fig6$panel09.$ext09")}}
# Durable historical reports/receipts for the specifically retired ignored raw caches.
foreach($phase09 in @('convergence_reanalysis','stationary_convergence')){
    foreach($name09 in @('REPORT.md','COMPLETION.md')){$paths09.Add("docs/paper_ready/$phase09/$name09")}
    foreach($name09 in @('audit.json','simulation.json','summary.json','table_audit.json')){$paths09.Add("results/paper_ready/$phase09/$name09")}
}
$paths09.Add('docs/paper_ready/stationary_convergence/REVIEW_REPORT.md')
$paths09.Add('docs/paper_ready/final_v3/fig6ij_fivelevel/REPORT.md')
$paths09.Add('results/paper_ready/final_v3/fig6ij_fivelevel/audit.json')
$paths09.Add('results/paper_ready/final_v3/fig6ij_fivelevel/validation.json')
foreach($path09 in $paths09){
    $item09=Get-Item -LiteralPath (Join-Path $repo09 $path09)
    if($path09 -match '/cache/|\.mat$|stdout|stderr|NOTION_BEFORE|/smoke/(fig|png)/' -or $item09.Length -gt 10MB){throw "Disallowed staging candidate $path09"}
}
& git switch main
if($LASTEXITCODE -ne 0){throw 'Branch switch failed'}
& git add -- $paths09.ToArray()
if($LASTEXITCODE -ne 0){throw 'Staging failed'}
$staged09=@(& git diff --cached --name-only)
if(@(Compare-Object ($paths09.ToArray()|Sort-Object) ($staged09|Sort-Object)).Count){throw 'Staged path mismatch'}
# Preserve the original historical report's existing trailing blank line;
# check all other whitespace rules and all intended files without changing it.
& git -c core.whitespace=-blank-at-eof diff --cached --check
if($LASTEXITCODE -ne 0){throw 'Whitespace validation failed'}
[pscustomobject]@{stagedFiles=$staged09.Count;stagedBytes=($paths09|ForEach-Object{(Get-Item -LiteralPath $_).Length}|Measure-Object -Sum).Sum}|ConvertTo-Json
& git diff --cached --stat
