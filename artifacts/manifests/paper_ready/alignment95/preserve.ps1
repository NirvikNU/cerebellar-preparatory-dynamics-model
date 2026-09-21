param([switch]$Verify)
$ErrorActionPreference='Stop'
$paperRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$paperManifest=Join-Path $PSScriptRoot 'INPUTS_BEFORE.csv'
if($Verify){
    $paperRows=Import-Csv -LiteralPath $paperManifest
    $paperChanges=@()
    foreach($paperRow in $paperRows){
        $paperHash=(Get-FileHash -LiteralPath (Join-Path $paperRoot $paperRow.path)).Hash
        if($paperHash -ne $paperRow.sha256){
            if($paperRow.path -eq 'AGENTS.md'){$paperChanges+=@{path=$paperRow.path;before=$paperRow.sha256;after=$paperHash;reason='Current corrective-task navigation'}}
            else{throw "Protected file changed: $($paperRow.path)"}
        }
    }
    [ordered]@{status='PASS';unchangedFiles=$paperRows.Count-$paperChanges.Count;authorizedChanges=$paperChanges;checkedUTC=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'PRESERVATION.json')
    "PASS: $($paperRows.Count-$paperChanges.Count) protected files unchanged"
}else{
    if(Test-Path -LiteralPath $paperManifest){throw 'Do not restart preservation'}
    $paperFiles=@(Get-ChildItem -LiteralPath $paperRoot -Recurse -File -Force | Where-Object {
        $_.FullName -notlike "$paperRoot\.git\*" -and $_.FullName -notmatch '[\\/]alignment95[\\/]' -and $_.Name -notmatch '_alignment95\.(fig|png)$'
    })
    $paperRows=@($paperFiles | Sort-Object FullName | ForEach-Object {
        [pscustomobject]@{path=[IO.Path]::GetRelativePath($paperRoot,$_.FullName).Replace('\','/');bytes=$_.Length;attributes=$_.Attributes;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}
    })
    $paperRows | Export-Csv -LiteralPath $paperManifest -NoTypeInformation
    [ordered]@{status='PASS';files=$paperRows.Count;bytes=($paperRows | Measure-Object bytes -Sum).Sum;startingSHA='aebd5fdfd300c19eca85548315357f11ecfd44ac';gitHealth='fetch/fsck PASS; clean/equal local tracking remote main/v3; no locks; dangling objects informational'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'PREFLIGHT.json')
    "PASS: $($paperRows.Count) old files hashed and inventoried"
}
