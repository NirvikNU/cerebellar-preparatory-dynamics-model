# Package only saved sources, without recomputation.
$ErrorActionPreference='Stop'
$taskRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$taskDocs=Join-Path $taskRoot 'docs/paper_ready/final_v3/fig6gh_fifteen23'
$taskResults='results/paper_ready/final_v3'
$taskNew=Join-Path $taskRoot "$taskResults/fig6gh_fifteen23"
$taskCheck=Get-Content -LiteralPath (Join-Path $taskNew 'validation.json') -Raw|ConvertFrom-Json
if($taskCheck.status -ne 'PASS'){throw 'Display validation failed'}
$taskZip=Join-Path $taskDocs 'Current_manuscript_source_tables_REVIEW.zip'
if(Test-Path -LiteralPath $taskZip){throw 'Preserve existing archive'}
$taskPaths=[Collections.Generic.List[string]]::new()
foreach($taskFile in @('Fig6ab_network_values.csv','Fig6de_network_values.csv','Fig6g_peak_speed.csv','Fig6h_matched_dispersion.csv','Fig6h_unmatched_all10.csv','ED7a_calibration_grid.csv','ED7b_network_values.csv','new_case_QC.csv')){$taskPaths.Add("$taskResults/$taskFile")}
foreach($taskSuffix in @('fig6ab_pvalues_correction/statistics.csv','fig6ab_pvalues_correction/paired_differences.csv','fig6degh_pvalues_correction/statistics.csv','fig6degh_pvalues_correction/paired_values.csv','fig6ij_fourlevel/Fig6ij_summaries.csv','fig6ij_fourlevel/Fig6ij_network_values.csv','fig6ij_fourlevel/statistics.json','fig6ij_ed7b_stats_correction/ED7b_tests.csv')){$taskPaths.Add("$taskResults/$taskSuffix")}
foreach($taskFile in @('all_saved_attempts.csv','canceled_request.csv','successful_rankings.csv','Fig6f_selected_trials.csv','Fig6f_four_trial_phase_means.csv')){$taskPaths.Add("$taskResults/fig6fgh_highrms14/$taskFile")}
foreach($taskFile in Get-ChildItem -LiteralPath $taskNew -File -Filter '*.csv'){$taskPaths.Add("$taskResults/fig6gh_fifteen23/$($taskFile.Name)")}
foreach($taskFile in @('selection.json','validation.json')){$taskPaths.Add("$taskResults/fig6gh_fifteen23/$taskFile")}
foreach($taskFile in @('REPORT.md','LEGENDS.md','PLAN.md','code_analyzer_complete.json')){$taskPaths.Add("docs/paper_ready/final_v3/fig6gh_fifteen23/$taskFile")}
$taskManifest=@($taskPaths|ForEach-Object{
    $taskFile=Get-Item -LiteralPath (Join-Path $taskRoot $_)
    [pscustomobject]@{path=$_;bytes=$taskFile.Length;sha256=(Get-FileHash -LiteralPath $taskFile.FullName -Algorithm SHA256).Hash}
})
$taskZipStream=[IO.File]::Open($taskZip,[IO.FileMode]::CreateNew)
$taskArchive=[IO.Compression.ZipArchive]::new($taskZipStream,[IO.Compression.ZipArchiveMode]::Create,$false)
try{foreach($taskRow in $taskManifest){[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($taskArchive,(Join-Path $taskRoot $taskRow.path),$taskRow.path,[IO.Compression.CompressionLevel]::Optimal)|Out-Null}}
finally{$taskArchive.Dispose();$taskZipStream.Dispose()}
$taskRead=[IO.Compression.ZipFile]::OpenRead($taskZip)
try{
    foreach($taskRow in $taskManifest){
        $taskStream=$taskRead.GetEntry($taskRow.path).Open()
        try{$taskHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($taskStream))}finally{$taskStream.Dispose()}
        if($taskHash -ne $taskRow.sha256){throw "Archive mismatch: $($taskRow.path)"}
    }
    if($taskRead.Entries.Count -ne $taskManifest.Count){throw 'Archive count mismatch'}
}finally{$taskRead.Dispose()}
[ordered]@{status='PASS';files=$taskManifest;zipBytes=(Get-Item -LiteralPath $taskZip).Length;zipSHA256=(Get-FileHash -LiteralPath $taskZip -Algorithm SHA256).Hash}|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $taskDocs 'source_archive_validation.json') -Encoding utf8
[pscustomobject]@{entries=$taskManifest.Count;bytes=(Get-Item -LiteralPath $taskZip).Length;status='PASS'}|ConvertTo-Json

# Independently verify every unrelated entry against the previous published ZIP.
$oldZip23=Join-Path $taskRoot 'docs/paper_ready/final_v3/fig6gh_representative17/Current_manuscript_source_tables_REVIEW.zip'
$old23=[IO.Compression.ZipFile]::OpenRead($oldZip23)
$new23=[IO.Compression.ZipFile]::OpenRead($taskZip)
$stable23=0
try{
    foreach($entry23 in $old23.Entries){
        if($entry23.FullName -match '/fig6gh_representative17/'){continue}
        $match23=$new23.GetEntry($entry23.FullName)
        if($null -eq $match23){throw 'Missing protected ZIP entry'}
        $left23=$entry23.Open();$right23=$match23.Open()
        try{
            $a23=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($left23))
            $b23=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($right23))
            if($a23 -ne $b23){throw ('Protected ZIP entry changed: '+$entry23.FullName)}
        }finally{$left23.Dispose();$right23.Dispose()}
        $stable23++
    }
}finally{$old23.Dispose();$new23.Dispose()}
if($stable23 -ne 21){throw 'Unexpected protected ZIP entry count'}
[ordered]@{status='PASS';unchangedPriorEntries=$stable23;newEntryCount=$taskManifest.Count;noScientificRecomputation=$true}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $taskDocs 'source_archive_preservation.json') -Encoding utf8
