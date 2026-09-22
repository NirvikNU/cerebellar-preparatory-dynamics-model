param([switch]$Verify)
$ErrorActionPreference='Stop'
$etaRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$etaManifest=Join-Path $PSScriptRoot 'RESUME_INPUTS.csv'
$etaReceipt=Join-Path $PSScriptRoot $(if($Verify){'RESUME_PRESERVATION.json'}else{'RESUME_INVENTORY.json'})
if(Test-Path -LiteralPath $etaReceipt){throw 'Refusing receipt overwrite'}
if($Verify){
    $etaRows=Import-Csv -LiteralPath $etaManifest
    foreach($etaRow in $etaRows){
        $etaPath=Join-Path $etaRoot $etaRow.path
        if(-not (Test-Path -LiteralPath $etaPath -PathType Leaf)){throw "Missing protected file: $($etaRow.path)"}
        if((Get-FileHash -LiteralPath $etaPath).Hash -ne $etaRow.sha256){throw "Changed protected file: $($etaRow.path)"}
    }
    [ordered]@{status='PASS';files=$etaRows.Count;checkedUTC=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath $etaReceipt
}else{
    if(Test-Path -LiteralPath $etaManifest){throw 'Do not restart resume inventory'}
    $etaKnown=@{}
    foreach($etaSource in @('artifacts/manifests/paper_ready/prediction/INPUTS_BEFORE.csv','artifacts/manifests/paper_ready/prediction/INVENTORY.csv')){
        foreach($etaRow in (Import-Csv -LiteralPath (Join-Path $etaRoot $etaSource))){$etaKnown[$etaRow.path]=$etaRow.sha256}
    }
    $etaFiles=Get-ChildItem -LiteralPath $etaRoot -Recurse -File -Force | Where-Object {
        $_.FullName -notlike "$etaRoot\.git\*" -and
        ($_.FullName -notmatch '[\\/]stabilization_eta[\\/]' -or $_.Name -in @('PREFLIGHT_STOP.md','PRESERVATION_PREFLIGHT.json'))
    }
    $etaRows=@(foreach($etaFile in ($etaFiles | Sort-Object FullName)){
        $etaRelative=[IO.Path]::GetRelativePath($etaRoot,$etaFile.FullName).Replace('\','/')
        $etaHash=(Get-FileHash -LiteralPath $etaFile.FullName).Hash
        if($etaKnown.ContainsKey($etaRelative) -and $etaKnown[$etaRelative] -ne $etaHash){throw "Historical hash mismatch: $etaRelative"}
        [pscustomobject]@{path=$etaRelative;bytes=$etaFile.Length;attributes=$etaFile.Attributes;sha256=$etaHash}
    })
    $etaRows | Export-Csv -LiteralPath $etaManifest -NoTypeInformation
    [ordered]@{status='PASS';files=$etaRows.Count;bytes=($etaRows | Measure-Object bytes -Sum).Sum;knownHistoricalHashes=$etaKnown.Count;checkedUTC=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath $etaReceipt
}
Get-Content -LiteralPath $etaReceipt
