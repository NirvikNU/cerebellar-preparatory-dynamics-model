param([ValidateSet('before','after')][string]$Phase)
$ErrorActionPreference='Stop'
$root13='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$docs13=Join-Path $root13 'docs/paper_ready/final_v3/fig6f_random5_18'
Set-Location -LiteralPath $root13
$manifest11=Join-Path $docs13 'preserved_before.json'
if($Phase -eq 'before'){
    if(Test-Path -LiteralPath $manifest11){throw 'Preserve original snapshot'}
    $rows11=@(Get-ChildItem -LiteralPath $root13 -Recurse -File -Force|ForEach-Object{
        $rel11=[IO.Path]::GetRelativePath($root13,$_.FullName).Replace('\','/')
        if($rel11 -notmatch '^\.git/' -and $rel11 -notmatch '/fig6f_random5_18/'){
            $hash11=$null
            if($rel11 -match '/cache/(fig6fgh_successful11|fig6fgh_final13|fig6fgh_highrms14|fig6gh_tweak15|fig6h_diffuse16|fig6gh_representative17)/' -or $rel11 -notmatch '/cache/' -or $rel11 -match '^results/paper_ready/cache/(stabilization_eta/raw_n\d+_e5_p1|final_v2/raw_n\d+_v2_p4)\.mat$'){$hash11=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}
            [pscustomobject]@{path=$rel11;bytes=$_.Length;modifiedTicks=$_.LastWriteTimeUtc.Ticks;sha256=$hash11}
        }
    })
    [ordered]@{root=$root13;utc=[DateTime]::UtcNow.ToString('o');entries=$rows11;trackedStatus=@(& git status --porcelain=v1 --untracked-files=no);untracked=@(& git ls-files --others --exclude-standard);ignored=@(& git ls-files --others --ignored --exclude-standard)}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath $manifest11 -Encoding utf8
    [pscustomobject]@{files=$rows11.Count;hashed=@($rows11|Where-Object sha256).Count;bytes=($rows11|Measure-Object bytes -Sum).Sum}|ConvertTo-Json
}else{
    $receipt11=Join-Path $docs13 'preservation_after.json'
    if(Test-Path -LiteralPath $receipt11){throw 'Preserve completed audit'}
    $rows11=(Get-Content -LiteralPath $manifest11 -Raw|ConvertFrom-Json).entries
    $hashed11=0;$metadata11=0
    foreach($r11 in $rows11){
        $p11=Join-Path $root13 $r11.path
        $f11=Get-Item -LiteralPath $p11

        if($f11.Length -ne $r11.bytes -or $f11.LastWriteTimeUtc.Ticks -ne $r11.modifiedTicks){throw "Original file changed: $($r11.path)"}
        $metadata11++
        if($r11.sha256){if((Get-FileHash -LiteralPath $p11 -Algorithm SHA256).Hash -ne $r11.sha256){throw "Original hash changed: $($r11.path)"};$hashed11++}
    }
    $out11=[ordered]@{status='PASS';unchangedMetadata=$metadata11;unchangedSHA256=$hashed11;deletedDependencies=0;allowedChangesToOriginals=@();utc=[DateTime]::UtcNow.ToString('o')}
    $out11|ConvertTo-Json|Set-Content -LiteralPath $receipt11 -Encoding utf8
    $out11|ConvertTo-Json
}
