$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
Set-Location -LiteralPath $repoRoot
$receiptPath=Join-Path $PSScriptRoot 'preservation_resume.json'
if(Test-Path -LiteralPath $receiptPath){throw 'Resume preservation receipt already exists'}
$allowed=@('README.md','docs/paper_ready/PAPER_CODE_INDEX.md','docs/paper_ready/CURRENT_REVIEW.md')
$rows=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'PROTECTED_BEFORE.csv')
$failures=@(foreach($row in $rows){
    if($row.path -in $allowed){continue}
    $file=Join-Path $repoRoot $row.path
    if(-not(Test-Path -LiteralPath $file) -or (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -ne $row.sha256){$row.path}
})
$receipt=[ordered]@{status=$(if($failures.Count){'FAIL'}else{'PASS'});files=$rows.Count;failures=$failures;allowedDocumentationEdits=$allowed;utc=[DateTime]::UtcNow.ToString('o')}
$receipt | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $receiptPath
if($failures.Count){throw 'Preservation failed'}
$receipt | ConvertTo-Json -Depth 5
