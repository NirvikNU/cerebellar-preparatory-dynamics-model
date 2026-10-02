param([ValidateSet('before','after')][string]$Phase)
$ErrorActionPreference='Stop'
$repo09='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$docs09=Join-Path $repo09 'docs/paper_ready/final_v3/fig6fgh_cleanup09'
$dest09=Join-Path $docs09 ("inventory_"+$Phase+'.json')
if(Test-Path -LiteralPath $dest09){throw 'Do not overwrite inventory'}
Set-Location -LiteralPath $repo09
$tracked09=@{}; & git --no-optional-locks ls-files | ForEach-Object {$tracked09[$_]=$true}
$files09=@(Get-ChildItem -LiteralPath $repo09 -Recurse -File -Force -ErrorAction Stop)
$rows09=@($files09 | ForEach-Object {
    $rel09=[IO.Path]::GetRelativePath($repo09,$_.FullName).Replace('\','/')
    [pscustomobject]@{path=$rel09;bytes=$_.Length;modifiedTicks=$_.LastWriteTimeUtc.Ticks;tracked=$tracked09.ContainsKey($rel09);reparse=[bool]($_.Attributes -band [IO.FileAttributes]::ReparsePoint)}
})
$totals09=@{}
foreach($row09 in $rows09){
    $parts09=$row09.path.Split('/')
    for($depth09=1;$depth09 -lt $parts09.Length;$depth09++){
        $dir09=($parts09[0..($depth09-1)] -join '/')
        if(-not $totals09.ContainsKey($dir09)){$totals09[$dir09]=[long]0}
        $totals09[$dir09]+=[long]$row09.bytes
    }
}
$dirs09=@($totals09.GetEnumerator()|ForEach-Object{[ordered]@{path=$_.Key;bytes=$_.Value}}|Sort-Object {[long]$_.bytes} -Descending)
$report09=[ordered]@{phase=$Phase;utc=[DateTime]::UtcNow.ToString('o');root=$repo09;totalBytes=($rows09|Measure-Object bytes -Sum).Sum;fileCount=$rows09.Count;entries=$rows09;directories=$dirs09;largestFiles=@($rows09|Sort-Object {[long]$_.bytes} -Descending|Select-Object -First 30)}
$report09|ConvertTo-Json -Depth 8|Set-Content -LiteralPath $dest09 -Encoding utf8
[ordered]@{phase=$Phase;totalBytes=$report09.totalBytes;fileCount=$report09.fileCount;largestDirectories=@($dirs09|Select-Object -First 35);largestFiles=@($report09.largestFiles|Select-Object -First 6)}|ConvertTo-Json -Depth 5
