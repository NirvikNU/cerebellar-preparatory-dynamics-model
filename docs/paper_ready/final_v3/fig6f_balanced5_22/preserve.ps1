param([ValidateSet('before','after')][string]$Phase)
$ErrorActionPreference='Stop'
$repo22='E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model'
$docs22=Join-Path $repo22 'docs/paper_ready/final_v3/fig6f_balanced5_22'
Set-Location -LiteralPath $repo22
$manifest22=Join-Path $docs22 'preservation_before.json'
if($Phase -eq 'before'){
    if(Test-Path -LiteralPath $manifest22){throw 'Preserve initial snapshot'}
    $entries22=@(Get-ChildItem -LiteralPath $repo22 -Recurse -File -Force|ForEach-Object {
        $rel22=[IO.Path]::GetRelativePath($repo22,$_.FullName).Replace('\','/')
        if($rel22 -notmatch '^\.git/' -and $rel22 -notmatch '/fig6f_balanced5_22/'){
            $digest22=$null
            if($rel22 -notmatch '/cache/' -or $rel22 -match '/cache/(fig6fgh_successful11|fig6fgh_highrms14)/'){
                $digest22=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            }
            [pscustomobject]@{path=$rel22;bytes=$_.Length;modifiedTicks=$_.LastWriteTimeUtc.Ticks;sha256=$digest22}
        }
    })
    [ordered]@{root=$repo22;utc=[DateTime]::UtcNow.ToString('o');head=(& git rev-parse HEAD);entries=$entries22;untracked=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6f_balanced5_22/'});ignored=@(& git ls-files --others --ignored --exclude-standard);trackedStatus=@(& git status --porcelain=v1 --untracked-files=no)}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath $manifest22 -Encoding utf8
    [ordered]@{status='PASS';files=$entries22.Count;hashed=@($entries22|Where-Object sha256).Count;bytes=($entries22|Measure-Object bytes -Sum).Sum}|ConvertTo-Json
}else{
    $output22=Join-Path $docs22 'preservation_after.json'
    if(Test-Path -LiteralPath $output22){throw 'Preserve completed audit'}
    $initial22=Get-Content -LiteralPath $manifest22 -Raw|ConvertFrom-Json
    $metadata22=0; $hashes22=0; $allowed22='docs/paper_ready/final_v3/CURRENT_PANEL_INDEX.md'
    foreach($entry22 in $initial22.entries){
        if($entry22.path -eq $allowed22){continue}
        $file22=Get-Item -LiteralPath (Join-Path $repo22 $entry22.path)
        if($file22.Length -ne $entry22.bytes -or $file22.LastWriteTimeUtc.Ticks -ne $entry22.modifiedTicks){throw ('Original metadata changed: '+$entry22.path)}
        $metadata22++
        if($entry22.sha256){
            if((Get-FileHash -LiteralPath $file22.FullName -Algorithm SHA256).Hash -ne $entry22.sha256){throw ('Original hash changed: '+$entry22.path)}
            $hashes22++
        }
    }
    $remaining22=@(& git ls-files --others --exclude-standard|Where-Object {$_ -notmatch '/fig6f_balanced5_22/'})
    if(@(Compare-Object @($initial22.untracked) $remaining22).Count){throw 'Unrelated untracked set changed'}
    $receipt22=[ordered]@{status='PASS';unchangedMetadata=$metadata22;unchangedSHA256=$hashes22;allowedExistingChanges=@($allowed22);unrelatedUntracked=$remaining22.Count;deletedDependencies=0;utc=[DateTime]::UtcNow.ToString('o')}
    $receipt22|ConvertTo-Json|Set-Content -LiteralPath $output22 -Encoding utf8
    $receipt22|ConvertTo-Json
}
