param([ValidateSet('before','after')][string]$Phase)
$ErrorActionPreference='Stop'
$root10='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$docs10=Join-Path $root10 'docs/paper_ready/final_v3/fig6fgh_success10'
Set-Location -LiteralPath $root10
$manifest10=Join-Path $docs10 'preserved_before.json'
$navigation10='docs/paper_ready/final_v3/CURRENT_PANEL_INDEX.md'
if($Phase -eq 'before'){
    if(Test-Path -LiteralPath $manifest10){throw 'Preserve original snapshot'}
    $rows10=@(Get-ChildItem -LiteralPath $root10 -Recurse -File -Force|ForEach-Object{
        $rel10=[IO.Path]::GetRelativePath($root10,$_.FullName).Replace('\','/')
        if($rel10 -notmatch '^\.git/' -and $rel10 -notmatch '/fig6fgh_success10/'){
            $hash10=$null
            if($rel10 -notmatch '/cache/' -or $rel10 -match '^results/paper_ready/cache/(stabilization_eta/raw_n\d+_e5_p1|final_v2/raw_n\d+_v2_p4)\.mat$'){$hash10=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}
            [pscustomobject]@{path=$rel10;bytes=$_.Length;modifiedTicks=$_.LastWriteTimeUtc.Ticks;sha256=$hash10}
        }
    })
    [ordered]@{root=$root10;utc=[DateTime]::UtcNow.ToString('o');entries=$rows10;trackedStatus=@(& git status --porcelain=v1 --untracked-files=no);untracked=@(& git ls-files --others --exclude-standard);ignored=@(& git ls-files --others --ignored --exclude-standard)}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath $manifest10 -Encoding utf8
    [pscustomobject]@{files=$rows10.Count;hashed=@($rows10|Where-Object sha256).Count;bytes=($rows10|Measure-Object bytes -Sum).Sum}|ConvertTo-Json
}else{
    $receipt10=Join-Path $docs10 'preservation_after.json'
    if(Test-Path -LiteralPath $receipt10){throw 'Preserve completed audit'}
    $rows10=(Get-Content -LiteralPath $manifest10 -Raw|ConvertFrom-Json).entries
    $hashed10=0;$metadata10=0
    foreach($r10 in $rows10){
        $p10=Join-Path $root10 $r10.path
        $f10=Get-Item -LiteralPath $p10
        if($r10.path -eq $navigation10){continue}
        if($f10.Length -ne $r10.bytes -or $f10.LastWriteTimeUtc.Ticks -ne $r10.modifiedTicks){throw "Original file changed: $($r10.path)"}
        $metadata10++
        if($r10.sha256){if((Get-FileHash -LiteralPath $p10 -Algorithm SHA256).Hash -ne $r10.sha256){throw "Original hash changed: $($r10.path)"};$hashed10++}
    }
    $out10=[ordered]@{status='PASS';unchangedMetadata=$metadata10;unchangedSHA256=$hashed10;deletedDependencies=0;allowedNavigationOnly=$navigation10;utc=[DateTime]::UtcNow.ToString('o')}
    $out10|ConvertTo-Json|Set-Content -LiteralPath $receipt10 -Encoding utf8
    $out10|ConvertTo-Json
}
