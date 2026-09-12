$ErrorActionPreference='Stop'
$postgoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$postgoMatlab=@(Get-ChildItem -LiteralPath $postgoRoot -File -Filter '*.m')
foreach($postgoDirectory in @('analysis','src','config','figures','workflows')){
    $postgoMatlab+=Get-ChildItem -LiteralPath (Join-Path $postgoRoot $postgoDirectory) -Recurse -File -Filter '*.m'
}
$postgoNames=@{}; foreach($postgoFile in $postgoMatlab){$postgoNames[$postgoFile.BaseName]=$postgoFile.FullName}
$postgoReferences=@(foreach($postgoFile in $postgoMatlab){
    $postgoText=Get-Content -LiteralPath $postgoFile.FullName -Raw
    foreach($postgoMatch in [regex]::Matches($postgoText,'\b((?:stage3_|stage_3_|run_stage3_|run_stage_3)\w*)\s*\(')){
        $postgoSymbol=$postgoMatch.Groups[1].Value
        if(-not $postgoNames.ContainsKey($postgoSymbol)){throw "Unresolved project function $postgoSymbol in $($postgoFile.FullName)"}
        [pscustomobject]@{source=[IO.Path]::GetRelativePath($postgoRoot,$postgoFile.FullName);symbol=$postgoSymbol;destination=[IO.Path]::GetRelativePath($postgoRoot,$postgoNames[$postgoSymbol])}
    }
})
$postgoReferences | Sort-Object source,symbol -Unique | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'POSTGO_FUNCTION_REFERENCES.csv') -NoTypeInformation
$postgoCheckedPaths=0
foreach($postgoDoc in @('README.md','AGENTS.md','MODEL_SPEC.md')){
    $postgoText=Get-Content -LiteralPath (Join-Path $postgoRoot $postgoDoc) -Raw
    foreach($postgoMatch in [regex]::Matches($postgoText,'`((?:analysis|src|config|figures|plots|results|artifacts|workflows)/[^`\r\n]+)`')){
        $postgoRelative=$postgoMatch.Groups[1].Value
        if($postgoRelative -match '[{}*]' -or $postgoRelative -match '\.\.\.') {continue}
        if(-not(Test-Path -LiteralPath (Join-Path $postgoRoot $postgoRelative))){throw "Broken active documentation path $postgoRelative in $postgoDoc"}
        $postgoCheckedPaths++
    }
}
$postgoNamesExpected=@('result_1_preparation_and_movement','result_2_preparatory_geometry','diagnostic_1_feasible_solution_map',
    'diagnostic_2_component_removal','result_3_prediction_validation','diagnostic_3_prediction_noise','diagnostic_4_prediction_specificity','diagnostic_5_postgo_noise_causal')
foreach($postgoName in $postgoNamesExpected){
    foreach($postgoExtension in @('fig','png')){
        if(-not(Test-Path -LiteralPath (Join-Path $postgoRoot "plots/stage_3/$postgoExtension/$postgoName.$postgoExtension"))){throw "Missing current figure $postgoName.$postgoExtension"}
    }
}
$postgoReceipt=[ordered]@{status='PASS';matlabFilesScanned=$postgoMatlab.Count;stage3FunctionReferences=$postgoReferences.Count;activeDocumentationPaths=$postgoCheckedPaths;currentFigurePairs=8;scope='Repository-wide project MATLAB function names and literal active root-document paths. Historical manifest path/hash records refer to their original checkpoints, not current executable dependencies.'}
$postgoReceipt | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'POSTGO_REFERENCE_CHECK.json') -Encoding utf8
$postgoReceipt
