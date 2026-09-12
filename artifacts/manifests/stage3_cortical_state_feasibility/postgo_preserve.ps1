param([switch]$Verify)
$ErrorActionPreference='Stop'
$postgoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$postgoManifest=Join-Path $PSScriptRoot 'POSTGO_INPUTS_BEFORE.csv'
if($Verify){
    $postgoRows=Import-Csv -LiteralPath $postgoManifest
    foreach($postgoRow in $postgoRows){
        $postgoPath=Join-Path $postgoRoot $postgoRow.path
        if(-not (Test-Path -LiteralPath $postgoPath -PathType Leaf)){throw "Missing baseline file: $($postgoRow.path)"}
        if((Get-FileHash -LiteralPath $postgoPath).Hash -ne $postgoRow.sha256){throw "Changed baseline file: $($postgoRow.path)"}
    }
    Write-Output "PASS: all $($postgoRows.Count) baseline files unchanged before cleanup"
}else{
    if(Test-Path -LiteralPath $postgoManifest){throw 'Baseline already exists; do not restart'}
    $postgoFiles=@(Get-ChildItem -LiteralPath $postgoRoot -File -Force)
    foreach($postgoDir in @('src','analysis','config','figures','plots','results','workflows','artifacts/manifests')){
        $postgoFiles+=Get-ChildItem -LiteralPath (Join-Path $postgoRoot $postgoDir) -Recurse -File -Force
    }
    $postgoFiles=@($postgoFiles | Where-Object {$_.Name -notlike 'POSTGO_*' -and $_.Name -notlike 'stage3_postgo_*' -and $_.Name -ne 'postgo_preserve.ps1'} | Sort-Object FullName -Unique)
    $postgoRows=@($postgoFiles | ForEach-Object {
        $postgoRelative=[IO.Path]::GetRelativePath($postgoRoot,$_.FullName).Replace('\','/')
        git ls-files --error-unmatch -- $postgoRelative 2>$null | Out-Null
        [pscustomobject]@{path=$postgoRelative;bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash;tracked=($LASTEXITCODE -eq 0)}
    })
    $postgoRows | Export-Csv -LiteralPath $postgoManifest -NoTypeInformation
    Write-Output "PASS: $($postgoRows.Count) checkpoint/scientific files inventoried and hashed"
}
