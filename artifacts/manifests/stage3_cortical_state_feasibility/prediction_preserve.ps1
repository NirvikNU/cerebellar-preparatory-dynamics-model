param([switch]$Verify)
$ErrorActionPreference='Stop'
$predRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$predManifest=Join-Path $PSScriptRoot 'PREDICTION_INPUTS_BEFORE.csv'
if($Verify){
  $predRows=Import-Csv -LiteralPath $predManifest
  foreach($predRow in $predRows){
    $predPath=Join-Path $predRoot $predRow.path
    if(-not (Test-Path -LiteralPath $predPath -PathType Leaf)){throw "Missing preserved asset $($predRow.path)"}
    if((Get-FileHash -LiteralPath $predPath).Hash -ne $predRow.sha256){throw "Preserved asset changed $($predRow.path)"}
  }
  Write-Output "PASS: $($predRows.Count) protected scientific/source/figure/provenance assets unchanged"
}else{
  if(Test-Path -LiteralPath $predManifest){throw 'Preservation baseline already exists'}
  $predFiles=@()
  foreach($predDir in @('src','analysis','config','figures','plots','results','workflows','artifacts/manifests')){
    $predFiles+=Get-ChildItem -LiteralPath (Join-Path $predRoot $predDir) -Recurse -File -Force
  }
  $predRows=@($predFiles | Where-Object {$_.Name -notlike 'PREDICTION_*' -and $_.Name -ne 'prediction_preserve.ps1'} | Sort-Object FullName -Unique | ForEach-Object {
    [pscustomobject]@{path=[IO.Path]::GetRelativePath($predRoot,$_.FullName);bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}
  })
  $predRows | Export-Csv -LiteralPath $predManifest -NoTypeInformation
  Write-Output "PASS: $($predRows.Count) pre-existing assets protected before simulation"
}
