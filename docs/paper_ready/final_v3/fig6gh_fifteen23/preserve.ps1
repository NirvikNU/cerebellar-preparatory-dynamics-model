param([ValidateSet('before','after')][string]$Phase)
$ErrorActionPreference='Stop'
$repo23='E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model'
$docs23=Join-Path $repo23 'docs/paper_ready/final_v3/fig6gh_fifteen23'
Set-Location -LiteralPath $repo23
$manifest23=Join-Path $docs23 'preservation_before.json'
if($Phase -eq 'before'){
    if(Test-Path -LiteralPath $manifest23){throw 'Preserve initial snapshot'}
    $entries23=@(Get-ChildItem -LiteralPath $repo23 -Recurse -File -Force|ForEach-Object {
        $rel23=[IO.Path]::GetRelativePath($repo23,$_.FullName).Replace('\','/')
        if($rel23 -notmatch '^\.git/' -and $rel23 -notmatch '/fig6gh_fifteen23/'){
            $digest23=$null
            if($rel23 -notmatch '/cache/' -or $rel23 -match '/cache/(fig6fgh_successful11|fig6fgh_highrms14|fig6gh_representative17)/'){
                $digest23=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            }
            [pscustomobject]@{path=$rel23;bytes=$_.Length;modifiedTicks=$_.LastWriteTimeUtc.Ticks;sha256=$digest23}
        }
    })
    [ordered]@{root=$repo23;utc=[DateTime]::UtcNow.ToString('o');head=(& git rev-parse HEAD);entries=$entries23;untracked=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6gh_fifteen23/'});ignored=@(& git ls-files --others --ignored --exclude-standard);trackedStatus=@(& git status --porcelain=v1 --untracked-files=no)}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath $manifest23 -Encoding utf8
    [ordered]@{status='PASS';files=$entries23.Count;hashed=@($entries23|Where-Object sha256).Count;bytes=($entries23|Measure-Object bytes -Sum).Sum}|ConvertTo-Json
}else{
    $output23=Join-Path $docs23 'preservation_after.json'
    if(Test-Path -LiteralPath $output23){throw 'Preserve completed audit'}
    $initial23=Get-Content -LiteralPath $manifest23 -Raw|ConvertFrom-Json
    $metadata23=0; $hashes23=0; $allowed23='docs/paper_ready/final_v3/CURRENT_PANEL_INDEX.md'
    foreach($entry23 in $initial23.entries){
        if($entry23.path -eq $allowed23){continue}
        $file23=Get-Item -LiteralPath (Join-Path $repo23 $entry23.path)
        if($file23.Length -ne $entry23.bytes -or $file23.LastWriteTimeUtc.Ticks -ne $entry23.modifiedTicks){throw ('Original metadata changed: '+$entry23.path)}
        $metadata23++
        if($entry23.sha256){
            if((Get-FileHash -LiteralPath $file23.FullName -Algorithm SHA256).Hash -ne $entry23.sha256){throw ('Original hash changed: '+$entry23.path)}
            $hashes23++
        }
    }
    $remaining23=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6gh_fifteen23/'})
    if(@(Compare-Object @($initial23.untracked) $remaining23).Count){throw 'Unrelated untracked set changed'}
    $receipt23=[ordered]@{status='PASS';unchangedMetadata=$metadata23;unchangedSHA256=$hashes23;allowedExistingChanges=@($allowed23);unrelatedUntracked=$remaining23.Count;deletedDependencies=0;utc=[DateTime]::UtcNow.ToString('o')}
    $receipt23|ConvertTo-Json|Set-Content -LiteralPath $output23 -Encoding utf8
    $receipt23|ConvertTo-Json
}
