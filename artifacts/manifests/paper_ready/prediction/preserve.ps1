param([switch]$Verify,[ValidateSet('PRESERVATION.json','PRESERVATION_FINAL.json')][string]$Receipt='PRESERVATION.json')
$ErrorActionPreference='Stop'
$peRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$peManifest=Join-Path $PSScriptRoot 'INPUTS_BEFORE.csv'
if($Verify){
    $peRows=Import-Csv -LiteralPath $peManifest
    foreach($peRow in $peRows){
        if((Get-FileHash -LiteralPath (Join-Path $peRoot $peRow.path)).Hash -ne $peRow.sha256){throw "Protected file changed: $($peRow.path)"}
    }
    [ordered]@{status='PASS';files=$peRows.Count;checkedUTC=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot $Receipt)
    "PASS: $($peRows.Count) files unchanged"
}else{
    if(Test-Path -LiteralPath $peManifest){throw 'Do not restart preservation'}
    $peFiles=@(Get-ChildItem -LiteralPath $peRoot -Recurse -File -Force | Where-Object {$_.FullName -notlike "$peRoot\.git\*" -and $_.FullName -notmatch '[\\/]paper_ready[\\/](cache[\\/])?prediction[\\/]'})
    $peRows=@($peFiles | Sort-Object FullName | ForEach-Object {[pscustomobject]@{path=[IO.Path]::GetRelativePath($peRoot,$_.FullName).Replace('\','/');bytes=$_.Length;attributes=$_.Attributes;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}})
    $peRows | Export-Csv -LiteralPath $peManifest -NoTypeInformation
    [ordered]@{status='PASS';files=$peRows.Count;bytes=($peRows | Measure-Object bytes -Sum).Sum;startingSHA='70fff703f8fd3074bef62ca9954a03bef50e4d99'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'PREFLIGHT.json')
    "PASS: $($peRows.Count) old files hashed"
}
