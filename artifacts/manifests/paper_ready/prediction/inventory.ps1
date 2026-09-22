$ErrorActionPreference='Stop'
$peRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$pePaths=@('analysis/paper_ready/prediction','figures/paper_ready/prediction','docs/paper_ready/prediction','results/paper_ready/prediction','results/paper_ready/cache/prediction','plots/paper_ready/prediction','artifacts/manifests/paper_ready/prediction')
$peIgnored=@{}
$peIgnoredPaths=@(& git -C $peRoot ls-files --others --ignored --exclude-standard -- $pePaths)
if($LASTEXITCODE -ne 0){throw 'Cannot inventory ignored task paths'}
foreach($peIgnoredPath in $peIgnoredPaths){$peIgnored[$peIgnoredPath]=$true}
$peRows=@(foreach($pePath in $pePaths){
    $peFull=Join-Path $peRoot $pePath
    if(-not(Test-Path -LiteralPath $peFull)){continue}
    foreach($peFile in Get-ChildItem -LiteralPath $peFull -File -Force -Recurse){
        if($peFile.Name -in @('INVENTORY.csv','INVENTORY.json','FINAL_GIT.json')){continue}
        $peRelative=[IO.Path]::GetRelativePath($peRoot,$peFile.FullName).Replace('\','/')
        $peCategory=switch -Wildcard ($peRelative){
            'results/paper_ready/cache/prediction/*' {'Required recovered raw series and full fitting evidence, local-only'; break}
            'analysis/*' {'New authorized prediction source'; break}
            'figures/*' {'New cache-only renderer'; break}
            'docs/*' {'Plan, derivation, legends and reviewed results'; break}
            'plots/*' {'Editable FIG or matching PNG master'; break}
            'results/*' {'Compact numerical results and independent validation'; break}
            default {'Preservation, validation and publication provenance'}
        }
        [pscustomobject]@{path=$peRelative;bytes=$peFile.Length;sha256=(Get-FileHash -LiteralPath $peFile.FullName).Hash;classification=$peCategory;action='RETAIN';ignored=$peIgnored.ContainsKey($peRelative)}
    }
})
$peRows | Sort-Object path | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'INVENTORY.csv') -NoTypeInformation
[ordered]@{status='PASS';files=$peRows.Count;bytes=($peRows | Measure-Object bytes -Sum).Sum;deleted=0;oldArtifactsModified=0;staged=0;commitCreated=$false;pushPerformed=$false;selfExclusions=@('INVENTORY.csv','INVENTORY.json','FINAL_GIT.json')} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'INVENTORY.json')
"Retained $($peRows.Count) task files; deleted none"
