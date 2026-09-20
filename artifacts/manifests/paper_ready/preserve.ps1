param([switch]$Verify)
$ErrorActionPreference='Stop'
$paperRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$paperManifest=Join-Path $PSScriptRoot 'INPUTS_BEFORE.csv'
if($Verify){
    $paperRows=Import-Csv -LiteralPath $paperManifest
    $paperDocumentChanges=@()
    foreach($paperRow in $paperRows){
        $paperCurrentHash=(Get-FileHash -LiteralPath (Join-Path $paperRoot $paperRow.path)).Hash
        if($paperCurrentHash -ne $paperRow.sha256){
            if($paperRow.path -in @('AGENTS.md','.gitignore')){
                $paperDocumentChanges+=@{path=$paperRow.path;before=$paperRow.sha256;after=$paperCurrentHash;reason='Authorized paper-only navigation / raw-cache ignore; review exact Git diff'}
            }else{throw "Protected asset changed: $($paperRow.path)"}
        }
    }
    [ordered]@{status='PASS';unchangedFiles=$paperRows.Count-$paperDocumentChanges.Count;authorizedDocumentChanges=$paperDocumentChanges;checkedUTC=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'PRESERVATION.json')
    Write-Output "PASS: $($paperRows.Count-$paperDocumentChanges.Count) protected files unchanged; $($paperDocumentChanges.Count) explicitly classified documentation changes"
}else{
    if(Test-Path -LiteralPath $paperManifest){throw 'Do not replace initial manifest'}
    $paperFiles=@(foreach($paperDir in @('src','analysis','config','figures','plots','results','workflows','third_party')){
        Get-ChildItem -LiteralPath (Join-Path $paperRoot $paperDir) -Recurse -File -Force | Where-Object { $_.FullName -notmatch '[\\/]paper_ready[\\/]' }
    })
    $paperFiles+=Get-ChildItem -LiteralPath $paperRoot -File -Force
    $paperRows=@($paperFiles | Sort-Object FullName -Unique | ForEach-Object {
        [pscustomobject]@{path=[IO.Path]::GetRelativePath($paperRoot,$_.FullName).Replace('\','/');bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}
    })
    $paperRows | Export-Csv -LiteralPath $paperManifest -NoTypeInformation
    $paperInventory=Get-ChildItem -LiteralPath $paperRoot -Force -Recurse -File | Where-Object {$_.FullName -notlike "$paperRoot\.git\*"} | ForEach-Object {
        [pscustomobject]@{path=[IO.Path]::GetRelativePath($paperRoot,$_.FullName).Replace('\','/');bytes=$_.Length;attributes=$_.Attributes}
    }
    $paperInventory | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'INVENTORY_BEFORE.csv') -NoTypeInformation
    Write-Output "PASS: $($paperRows.Count) protected files hashed; $($paperInventory.Count) non-Git files inventoried"
}
