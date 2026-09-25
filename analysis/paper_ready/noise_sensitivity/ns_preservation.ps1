param([ValidateSet('before','after')][string]$Phase='before')
$ErrorActionPreference='Stop'
$repoRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$receiptRoot=Join-Path $repoRoot 'artifacts/manifests/paper_ready/noise_sensitivity'
New-Item -ItemType Directory -Force -Path $receiptRoot | Out-Null
$csv=Join-Path $receiptRoot 'PROTECTED_BEFORE.csv'
if($Phase -eq 'before') {
    if(Test-Path -LiteralPath $csv){throw 'Preservation inventory already exists'}
    $rows=Get-ChildItem -LiteralPath $repoRoot -File -Force -Recurse | Where-Object {
        $_.FullName -notlike "$repoRoot\.git\*" -and $_.FullName -notmatch '\\paper_ready\\(?:cache\\)?noise_sensitivity\\'
    } | ForEach-Object {
        [pscustomobject]@{path=$_.FullName.Substring($repoRoot.Length+1).Replace('\','/');bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}
    }
    $rows | Export-Csv -LiteralPath $csv -NoTypeInformation
    [pscustomobject]@{status='PASS';phase=$Phase;files=$rows.Count;bytes=($rows|Measure-Object bytes -Sum).Sum;utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $receiptRoot 'preservation_before.json')
} else {
    $rows=Import-Csv -LiteralPath $csv
    $fail=@($rows | Where-Object {
        $path=Join-Path $repoRoot $_.path
        -not(Test-Path -LiteralPath $path) -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $_.sha256
    })
    [pscustomobject]@{status=$(if($fail.Count){'FAIL'}else{'PASS'});phase=$Phase;files=$rows.Count;failures=$fail;utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $receiptRoot 'preservation_after.json')
    if($fail.Count){throw 'Protected file mismatch'}
}
