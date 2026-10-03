param([ValidateSet('before','after')][string]$Phase)
$ErrorActionPreference='Stop'
$repo21='E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model'
$docs21=Join-Path $repo21 'docs/paper_ready/final_v3/fig6f_scatter21'
Set-Location -LiteralPath $repo21
$manifest21=Join-Path $docs21 'preservation_before.json'
if($Phase -eq 'before'){
    if(Test-Path -LiteralPath $manifest21){throw 'Preserve initial snapshot'}
    $entries21=@(Get-ChildItem -LiteralPath $repo21 -Recurse -File -Force|ForEach-Object {
        $rel21=[IO.Path]::GetRelativePath($repo21,$_.FullName).Replace('\','/')
        if($rel21 -notmatch '^\.git/' -and $rel21 -notmatch '/fig6f_scatter21/'){
            $digest21=$null
            if($rel21 -notmatch '/cache/' -or $rel21 -match '/cache/(fig6fgh_successful11|fig6fgh_highrms14)/'){
                $digest21=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            }
            [pscustomobject]@{path=$rel21;bytes=$_.Length;modifiedTicks=$_.LastWriteTimeUtc.Ticks;sha256=$digest21}
        }
    })
    [ordered]@{root=$repo21;utc=[DateTime]::UtcNow.ToString('o');head=(& git rev-parse HEAD);entries=$entries21;untracked=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6f_scatter21/'});ignored=@(& git ls-files --others --ignored --exclude-standard);trackedStatus=@(& git status --porcelain=v1 --untracked-files=no)}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath $manifest21 -Encoding utf8
    [ordered]@{status='PASS';files=$entries21.Count;hashed=@($entries21|Where-Object sha256).Count;bytes=($entries21|Measure-Object bytes -Sum).Sum}|ConvertTo-Json
}else{
    $output21=Join-Path $docs21 'preservation_after.json'
    if(Test-Path -LiteralPath $output21){throw 'Preserve completed audit'}
    $initial21=Get-Content -LiteralPath $manifest21 -Raw|ConvertFrom-Json
    $metadata21=0; $hashes21=0; $allowed21='docs/paper_ready/final_v3/CURRENT_PANEL_INDEX.md'
    foreach($entry21 in $initial21.entries){
        if($entry21.path -eq $allowed21){continue}
        $file21=Get-Item -LiteralPath (Join-Path $repo21 $entry21.path)
        if($file21.Length -ne $entry21.bytes -or $file21.LastWriteTimeUtc.Ticks -ne $entry21.modifiedTicks){throw ('Original metadata changed: '+$entry21.path)}
        $metadata21++
        if($entry21.sha256){
            if((Get-FileHash -LiteralPath $file21.FullName -Algorithm SHA256).Hash -ne $entry21.sha256){throw ('Original hash changed: '+$entry21.path)}
            $hashes21++
        }
    }
    $remaining21=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6f_scatter21/'})
    if(@(Compare-Object @($initial21.untracked) $remaining21).Count){throw 'Unrelated untracked set changed'}
    $receipt21=[ordered]@{status='PASS';unchangedMetadata=$metadata21;unchangedSHA256=$hashes21;allowedExistingChanges=@($allowed21);unrelatedUntracked=$remaining21.Count;deletedDependencies=0;utc=[DateTime]::UtcNow.ToString('o')}
    $receipt21|ConvertTo-Json|Set-Content -LiteralPath $output21 -Encoding utf8
    $receipt21|ConvertTo-Json
}
