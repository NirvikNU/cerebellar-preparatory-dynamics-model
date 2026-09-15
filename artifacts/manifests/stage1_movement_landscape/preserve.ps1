param([switch]$Verify,[string]$ReceiptName='PRESERVATION.json')
$ErrorActionPreference='Stop'
$landRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$landManifest=Join-Path $PSScriptRoot 'INPUTS_BEFORE.csv'
if($Verify){
    if($ReceiptName -notin @('PRESERVATION.json','FINAL_PRESERVATION.json')){throw 'Unrecognized preservation receipt path'}
    $landRows=Import-Csv -LiteralPath $landManifest
    foreach($landRow in $landRows){
        if((Get-FileHash -LiteralPath (Join-Path $landRoot $landRow.path)).Hash -ne $landRow.sha256){throw "Protected asset changed: $($landRow.path)"}
    }
    [ordered]@{status='PASS';unchangedFiles=$landRows.Count;checkedUTC=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot $ReceiptName)
    Write-Output "PASS: $($landRows.Count) existing protected assets unchanged"
}else{
    if(Test-Path -LiteralPath $landManifest){throw 'Do not replace initial manifest'}
    $landFiles=@(foreach($landDir in @('src','analysis','config','figures','plots','results','workflows')){
        Get-ChildItem -LiteralPath (Join-Path $landRoot $landDir) -Recurse -File -Force
    })
    $landRows=@($landFiles | Sort-Object FullName -Unique | ForEach-Object {
        [pscustomobject]@{path=[IO.Path]::GetRelativePath($landRoot,$_.FullName).Replace('\','/');bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}
    })
    $landRows | Export-Csv -LiteralPath $landManifest -NoTypeInformation
    Write-Output "PASS: $($landRows.Count) existing scientific/code/figure assets hashed"
}
