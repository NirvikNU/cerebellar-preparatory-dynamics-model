param([ValidateSet('before','after')][string]$Phase)
$ErrorActionPreference='Stop'
$repo20='E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model'
$docs20=Join-Path $repo20 'docs/paper_ready/final_v3/fig6f_contrast20'
Set-Location -LiteralPath $repo20
$manifest20=Join-Path $docs20 'preservation_before.json'
if($Phase -eq 'before'){
    if(Test-Path -LiteralPath $manifest20){throw 'Preserve initial snapshot'}
    $entries20=@(Get-ChildItem -LiteralPath $repo20 -Recurse -File -Force|ForEach-Object {
        $rel20=[IO.Path]::GetRelativePath($repo20,$_.FullName).Replace('\','/')
        if($rel20 -notmatch '^\.git/' -and $rel20 -notmatch '/fig6f_contrast20/'){
            $digest20=$null
            if($rel20 -notmatch '/cache/' -or $rel20 -match '/cache/(fig6fgh_successful11|fig6fgh_highrms14)/'){
                $digest20=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            }
            [pscustomobject]@{path=$rel20;bytes=$_.Length;modifiedTicks=$_.LastWriteTimeUtc.Ticks;sha256=$digest20}
        }
    })
    [ordered]@{root=$repo20;utc=[DateTime]::UtcNow.ToString('o');head=(& git rev-parse HEAD);entries=$entries20;untracked=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6f_contrast20/'});ignored=@(& git ls-files --others --ignored --exclude-standard);trackedStatus=@(& git status --porcelain=v1 --untracked-files=no)}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath $manifest20 -Encoding utf8
    [ordered]@{status='PASS';files=$entries20.Count;hashed=@($entries20|Where-Object sha256).Count;bytes=($entries20|Measure-Object bytes -Sum).Sum}|ConvertTo-Json
}else{
    $output20=Join-Path $docs20 'preservation_after.json'
    if(Test-Path -LiteralPath $output20){throw 'Preserve completed audit'}
    $initial20=Get-Content -LiteralPath $manifest20 -Raw|ConvertFrom-Json
    $metadata20=0; $hashes20=0; $allowed20='docs/paper_ready/final_v3/CURRENT_PANEL_INDEX.md'
    foreach($entry20 in $initial20.entries){
        if($entry20.path -eq $allowed20){continue}
        $file20=Get-Item -LiteralPath (Join-Path $repo20 $entry20.path)
        if($file20.Length -ne $entry20.bytes -or $file20.LastWriteTimeUtc.Ticks -ne $entry20.modifiedTicks){throw ('Original metadata changed: '+$entry20.path)}
        $metadata20++
        if($entry20.sha256){
            if((Get-FileHash -LiteralPath $file20.FullName -Algorithm SHA256).Hash -ne $entry20.sha256){throw ('Original hash changed: '+$entry20.path)}
            $hashes20++
        }
    }
    $remaining20=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6f_contrast20/'})
    if(@(Compare-Object @($initial20.untracked) $remaining20).Count){throw 'Unrelated untracked set changed'}
    $receipt20=[ordered]@{status='PASS';unchangedMetadata=$metadata20;unchangedSHA256=$hashes20;allowedExistingChanges=@($allowed20);unrelatedUntracked=$remaining20.Count;deletedDependencies=0;utc=[DateTime]::UtcNow.ToString('o')}
    $receipt20|ConvertTo-Json|Set-Content -LiteralPath $output20 -Encoding utf8
    $receipt20|ConvertTo-Json
}
