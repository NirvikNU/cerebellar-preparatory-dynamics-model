param([ValidateSet('before','after')][string]$Phase='before')
$ErrorActionPreference='Stop'
$repoRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
Set-Location -LiteralPath $repoRoot
$outRoot=$PSScriptRoot
$csv=Join-Path $outRoot 'PROTECTED_BEFORE.csv'
$receipt=Join-Path $outRoot "preservation_$Phase.json"
if(Test-Path -LiteralPath $receipt){throw 'Refuse to overwrite preservation receipt'}
if($Phase -eq 'before') {
    if(Test-Path -LiteralPath $csv){throw 'Inventory already exists'}
    $known=@{}
    foreach($row in (Import-Csv -LiteralPath 'artifacts/manifests/paper_ready/noise_sensitivity/PROTECTED_BEFORE.csv')) {
        $known[$row.path]=$row.sha256
    }
    $tracked=@{}; git ls-files | ForEach-Object {$tracked[$_]=$true}
    if($LASTEXITCODE){throw 'Tracked inventory failed'}
    $ignored=@{}; git ls-files --others --ignored --exclude-standard | ForEach-Object {$ignored[$_]=$true}
    if($LASTEXITCODE){throw 'Ignored inventory failed'}
    $files=@(Get-ChildItem -LiteralPath $repoRoot -File -Force -Recurse | Where-Object {
        $_.FullName -notlike "$repoRoot\.git\*" -and $_.FullName -notmatch '\\paper_ready\\(?:cache\\)?final_v2\\'
    } | Sort-Object FullName)
    $rows=@(foreach($file in $files) {
        $rel=[IO.Path]::GetRelativePath($repoRoot,$file.FullName).Replace('\','/')
        $hash=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
        if($known.ContainsKey($rel)) {
            if($known[$rel] -ne $hash){throw "Protected mismatch: $rel"}
            $known.Remove($rel)
        }
        $state=if($tracked.ContainsKey($rel)){'tracked'}elseif($ignored.ContainsKey($rel)){'ignored'}else{'untracked'}
        $class=if($rel -like 'results/paper_ready/cache/*'){'raw reproducibility evidence'}elseif($state -eq 'ignored'){'local scientific asset or audit/log; retain pending review'}else{'durable science/code/documentation/infrastructure'}
        [pscustomobject]@{path=$rel;bytes=$file.Length;sha256=$hash;attributes=[string]$file.Attributes;gitState=$state;classification=$class;action='retain; no deletion authorized by classification alone'}
    })
    if($known.Count){throw "Missing protected files: $($known.Keys -join ', ')"}
    $rows | Export-Csv -LiteralPath $csv -NoTypeInformation
    [ordered]@{status='PASS';phase=$Phase;files=$rows.Count;bytes=($rows|Measure-Object bytes -Sum).Sum;previousProtectedRows=2327;utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath $receipt
} else {
    $rows=Import-Csv -LiteralPath $csv
    $allowed=@('README.md','docs/paper_ready/PAPER_CODE_INDEX.md','docs/paper_ready/CURRENT_REVIEW.md')
    $fail=@(foreach($row in $rows) {
        if($row.path -in $allowed){continue}
        $path=Join-Path $repoRoot $row.path
        if(-not(Test-Path -LiteralPath $path) -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $row.sha256){$row}
    })
    [ordered]@{status=$(if($fail.Count){'FAIL'}else{'PASS'});phase=$Phase;files=$rows.Count;allowedDocumentationEdits=$allowed;failures=$fail;utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $receipt
    if($fail.Count){throw 'Protected preservation failure'}
}
Get-Content -LiteralPath $receipt
