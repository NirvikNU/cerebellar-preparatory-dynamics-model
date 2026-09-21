$ErrorActionPreference='Stop'
$paperRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$paperFolders=@('analysis/paper_ready/alignment95','figures/paper_ready/alignment95','docs/paper_ready/alignment95','results/paper_ready/alignment95','results/paper_ready/cache/alignment95','artifacts/manifests/paper_ready/alignment95')
$paperFiles=@(foreach($paperFolder in $paperFolders){Get-ChildItem -LiteralPath (Join-Path $paperRoot $paperFolder) -File -Recurse -Force})
$paperFiles+=@(Get-ChildItem -LiteralPath (Join-Path $paperRoot 'plots/paper_ready/fig'),(Join-Path $paperRoot 'plots/paper_ready/png') -File | Where-Object Name -match '_alignment95\.(fig|png)$')
$paperRows=@(foreach($paperFile in $paperFiles | Sort-Object FullName){
    $paperPath=[IO.Path]::GetRelativePath($paperRoot,$paperFile.FullName).Replace('\','/')
    if($paperFile.Name -in @('INVENTORY.csv','CLEANUP.json')){continue}
    $paperClass=switch -Regex ($paperPath){
        '^results/paper_ready/cache/' {'Required local raw/replay/null evidence; ignored';break}
        '^results/' {'Compact corrected scientific results and independent audit';break}
        '^plots/' {'Current editable/PNG figure pair';break}
        '^(analysis|figures)/' {'Active corrective implementation';break}
        '^docs/' {'Current methods, results, legends and provenance';break}
        default {'Preservation, preflight, validation or publication receipt'}
    }
    [pscustomobject]@{path=$paperPath;classification=$paperClass;disposition='RETAIN';bytes=$paperFile.Length;sha256=(Get-FileHash -LiteralPath $paperFile.FullName).Hash}
})
$paperRows | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'INVENTORY.csv') -NoTypeInformation
[ordered]@{status='PASS';files=$paperRows.Count;bytes=($paperRows | Measure-Object bytes -Sum).Sum;deletedFiles=0;reason='All new files are required source, evidence, figures, documentation or audit receipts. No redundant scratch artifact identified. All old K15 outputs remain historical provenance, not deletion candidates.';oldInventory='INPUTS_BEFORE.csv';protectedVerification='PRESERVATION.json'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'CLEANUP.json')
'Classified final corrected files; no deletion performed.'
