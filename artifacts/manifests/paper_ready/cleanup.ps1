$ErrorActionPreference='Stop'
$paperRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$paperExpected='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
if($paperRoot -ne $paperExpected){throw 'Unexpected cleanup root'}
if(Test-Path -LiteralPath (Join-Path $PSScriptRoot 'CLEANUP.json')){throw 'Cleanup already completed; do not rerun'}
$paperFigures=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'FIGURES.json') -Raw | ConvertFrom-Json
if(@($paperFigures.figures).Count -ne 4){throw 'Four completed figure pairs are required'}
$paperStatic=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'STATIC_FINAL.json') -Raw | ConvertFrom-Json
if(@($paperStatic.PSObject.Properties | Where-Object {$_.Value.Count -gt 0}).Count){throw 'Code Analyzer did not pass'}
foreach($paperGate in @('results/paper_ready/independent_audit.json','results/paper_ready/control_audit.json','artifacts/manifests/paper_ready/PRESERVATION.json')){
    $paperReceipt=Get-Content -LiteralPath (Join-Path $paperRoot $paperGate) -Raw | ConvertFrom-Json
    if($paperReceipt.status -ne 'PASS'){throw "Unpassed cleanup gate: $paperGate"}
}
$paperRows=@(foreach($paperRelativeRoot in @('analysis/paper_ready','figures/paper_ready','plots/paper_ready','results/paper_ready','docs/paper_ready','artifacts/manifests/paper_ready')){
    Get-ChildItem -LiteralPath (Join-Path $paperRoot $paperRelativeRoot) -Recurse -File -Force | ForEach-Object {
        $paperRelative=[IO.Path]::GetRelativePath($paperRoot,$_.FullName).Replace('\','/')
        $paperClass='retained provenance / validation evidence'
        if($paperRelative -like '*/cache/*'){$paperClass='retained local-only raw scientific evidence'}
        elseif($paperRelative -like 'analysis/*' -or $paperRelative -like 'figures/*'){$paperClass='retained active implementation / independent audit'}
        elseif($paperRelative -like 'plots/*'){$paperClass='retained current editable or rendered figure'}
        elseif($paperRelative -like 'docs/*'){$paperClass='retained locked plan / methods / captions / report'}
        elseif($paperRelative -like 'results/*'){$paperClass='retained source data / scientific result'}
        [pscustomobject]@{path=$paperRelative;bytes=$_.Length;classification=$paperClass;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}
    }
})
# Inventory and classify before the only permitted removal.
$paperProgress='results/paper_ready/geometry_progress.csv'
$paperProgressRow=$paperRows | Where-Object {$_.path -eq $paperProgress}
$paperFinalRow=$paperRows | Where-Object {$_.path -eq 'results/paper_ready/geometry_map.csv'}
if($paperProgressRow){
    if($paperProgressRow.sha256 -ne $paperFinalRow.sha256){throw 'Progress CSV is not an exact duplicate; preserve it'}
    $paperProgressRow.classification='remove exact duplicate of final geometry_map.csv; no unique evidence'
}
$paperRows | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'CLEANUP_INVENTORY.csv') -NoTypeInformation
if($paperProgressRow){
    $paperTarget=(Resolve-Path -LiteralPath (Join-Path $paperRoot $paperProgress)).Path
    $paperAllowed=Join-Path $paperExpected 'results\paper_ready\geometry_progress.csv'
    if($paperTarget -ne $paperAllowed){throw 'Unexpected removal target'}
    Remove-Item -LiteralPath $paperTarget
}
[ordered]@{status='PASS';inventoriedFiles=$paperRows.Count;removed=@($paperProgressRow.path);reason='Only byte-identical progress CSV removed; final table retained';rawEvidence='Retained in ignored results/paper_ready/cache';existingScientificFilesDeleted=0} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'CLEANUP.json')
