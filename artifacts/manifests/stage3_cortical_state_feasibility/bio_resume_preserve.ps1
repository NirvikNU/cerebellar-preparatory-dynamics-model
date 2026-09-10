$ErrorActionPreference='Stop'
$resumeRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$output=Join-Path $PSScriptRoot 'BIO_RESUME_BEFORE.csv'
if(Test-Path -LiteralPath $output){throw 'Resume baseline already exists'}
$old=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'BIO_INPUTS_BEFORE.csv')
foreach($r in $old){if((Get-FileHash -LiteralPath (Join-Path $resumeRoot $r.path)).Hash -ne $r.sha256){throw "Prior evidence changed: $($r.path)"}}
$cache=Join-Path $resumeRoot 'results/stage_3/current/cache/biological_revision/primary_01.mat'
if((Get-FileHash -LiteralPath $cache).Hash -ne '57B2F657D8E30DA703E4429D03DCFE1147755933482BA05F7632C18868C3543C'){throw 'Candidate cache hash changed'}
$rows=Get-ChildItem -LiteralPath $resumeRoot -Recurse -Force -File | Where-Object {
    -not $_.FullName.StartsWith(($resumeRoot+'\.git\'),[StringComparison]::OrdinalIgnoreCase) -and
    -not $_.FullName.StartsWith(($resumeRoot+'\third_party\'),[StringComparison]::OrdinalIgnoreCase)
} | ForEach-Object {[pscustomobject]@{path=$_.FullName.Substring($resumeRoot.Length+1);bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}}
$rows | Export-Csv -LiteralPath $output -NoTypeInformation
Write-Output "PASS: $($old.Count) old files and native candidate unchanged; $($rows.Count) resume baseline files"
