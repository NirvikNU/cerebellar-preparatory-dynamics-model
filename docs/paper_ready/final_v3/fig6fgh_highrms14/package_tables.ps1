# Assemble already validated source tables without changing or recalculating values.
$ErrorActionPreference='Stop'
$taskRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$taskDocs=Join-Path $taskRoot 'docs/paper_ready/final_v3/fig6fgh_highrms14'
$taskResults='results/paper_ready/final_v3'
$taskNew=Join-Path $taskRoot "$taskResults/fig6fgh_highrms14"
foreach($taskReceipt in @('saved_output_validation.json','validation.json')){
    $taskCheck=Get-Content -LiteralPath (Join-Path $taskNew $taskReceipt) -Raw|ConvertFrom-Json
    if($taskCheck.status -ne 'PASS'){throw "Required validation not passed: $taskReceipt"}
}
$taskZip=Join-Path $taskDocs 'Current_manuscript_source_tables_FINAL.zip'
if(Test-Path -LiteralPath $taskZip){throw 'Preserve existing source archive'}
$taskPaths=[Collections.Generic.List[string]]::new()
foreach($taskFile in @('Fig6ab_network_values.csv','Fig6de_network_values.csv','Fig6g_peak_speed.csv','Fig6h_matched_dispersion.csv','Fig6h_unmatched_all10.csv','ED7a_calibration_grid.csv','ED7b_network_values.csv','new_case_QC.csv')){$taskPaths.Add("$taskResults/$taskFile")}
foreach($taskSuffix in @('fig6ab_pvalues_correction/statistics.csv','fig6ab_pvalues_correction/paired_differences.csv','fig6degh_pvalues_correction/statistics.csv','fig6degh_pvalues_correction/paired_values.csv','fig6ij_fourlevel/Fig6ij_summaries.csv','fig6ij_fourlevel/Fig6ij_network_values.csv','fig6ij_fourlevel/statistics.json','fig6ij_ed7b_stats_correction/ED7b_tests.csv')){$taskPaths.Add("$taskResults/$taskSuffix")}
foreach($taskFile in Get-ChildItem -LiteralPath $taskNew -File -Filter '*.csv'){$taskPaths.Add("$taskResults/fig6fgh_highrms14/$($taskFile.Name)")}
foreach($taskFile in @('selection.json','saved_output_validation.json','validation.json','final_figure_validation.json')){$taskPaths.Add("$taskResults/fig6fgh_highrms14/$taskFile")}
foreach($taskFile in @('LEGENDS.md','DEPENDENCIES.md','REPORT.md','EMPIRICAL_TEMPLATE.md')){$taskPaths.Add("docs/paper_ready/final_v3/fig6fgh_highrms14/$taskFile")}
$taskManifest=@($taskPaths|ForEach-Object{
    $taskFile=Get-Item -LiteralPath (Join-Path $taskRoot $_)
    [pscustomobject]@{path=$_;bytes=$taskFile.Length;sha256=(Get-FileHash -LiteralPath $taskFile.FullName -Algorithm SHA256).Hash}
})
$taskZipStream=[IO.File]::Open($taskZip,[IO.FileMode]::CreateNew)
$taskArchive=[IO.Compression.ZipArchive]::new($taskZipStream,[IO.Compression.ZipArchiveMode]::Create,$false)
try{
    foreach($taskRow in $taskManifest){[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($taskArchive,(Join-Path $taskRoot $taskRow.path),$taskRow.path,[IO.Compression.CompressionLevel]::Optimal)|Out-Null}
}finally{$taskArchive.Dispose();$taskZipStream.Dispose()}
$taskRead=[IO.Compression.ZipFile]::OpenRead($taskZip)
try{
    foreach($taskRow in $taskManifest){
        $taskEntry=$taskRead.GetEntry($taskRow.path)
        $taskStream=$taskEntry.Open();$taskSHA=[Security.Cryptography.SHA256]::Create()
        try{$taskHash=[Convert]::ToHexString($taskSHA.ComputeHash($taskStream))}finally{$taskStream.Dispose();$taskSHA.Dispose()}
        if($taskHash -ne $taskRow.sha256){throw "Archive content mismatch: $($taskRow.path)"}
    }
    if($taskRead.Entries.Count -ne $taskManifest.Count){throw 'Archive entry count mismatch'}
}finally{$taskRead.Dispose()}
[ordered]@{status='PASS';files=$taskManifest;zipBytes=(Get-Item -LiteralPath $taskZip).Length;zipSHA256=(Get-FileHash -LiteralPath $taskZip -Algorithm SHA256).Hash}|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $taskDocs 'source_archive_validation.json') -Encoding utf8
[pscustomobject]@{entries=$taskManifest.Count;zipBytes=(Get-Item -LiteralPath $taskZip).Length;status='PASS'}|ConvertTo-Json
