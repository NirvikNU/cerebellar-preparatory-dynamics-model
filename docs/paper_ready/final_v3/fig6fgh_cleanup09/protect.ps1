param([ValidateSet('before','verify')][string]$Phase)
$ErrorActionPreference='Stop'
$root09='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$folder09=Join-Path $root09 'docs/paper_ready/final_v3/fig6fgh_cleanup09'
$manifest09=Join-Path $folder09 'protected_hashes.json'
if($Phase -eq 'before'){
    if(Test-Path -LiteralPath $manifest09){throw 'Preserve original hash manifest'}
    $files09=Get-ChildItem -LiteralPath $root09 -Recurse -File -Force | Where-Object {
        $r09=[IO.Path]::GetRelativePath($root09,$_.FullName).Replace('\','/')
        $r09 -notmatch '^\.git/' -and $r09 -notmatch '/fig6fgh_cleanup09/' -and (
            $r09 -notmatch '/cache/' -or
            $r09 -match '^results/paper_ready/cache/stabilization_eta/raw_n\d+_e5_p1\.mat$' -or
            $r09 -match '^results/paper_ready/cache/final_v2/raw_n\d+_v2_p4\.mat$')
    }
    $rows09=@($files09|ForEach-Object{[pscustomobject]@{path=[IO.Path]::GetRelativePath($root09,$_.FullName).Replace('\','/');bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}})
    $rows09|ConvertTo-Json -Depth 5|Set-Content -LiteralPath $manifest09 -Encoding utf8
    [ordered]@{files=$rows09.Count;bytes=($rows09|Measure-Object bytes -Sum).Sum}|ConvertTo-Json
}else{
    $rows09=Get-Content -LiteralPath $manifest09 -Raw|ConvertFrom-Json
    foreach($r09 in $rows09){$p09=Join-Path $root09 $r09.path;if(-not(Test-Path -LiteralPath $p09)){throw "Protected missing: $($r09.path)"};if((Get-FileHash -LiteralPath $p09 -Algorithm SHA256).Hash -ne $r09.sha256){throw "Protected mismatch: $($r09.path)"}}
    [ordered]@{status='PASS';protectedFiles=$rows09.Count;allHashesUnchanged=$true}|ConvertTo-Json
}
