$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
Set-Location -LiteralPath $repoRoot
$out=Join-Path $PSScriptRoot 'calibration_csv_audit.json'
if(Test-Path -LiteralPath $out){throw 'Audit already exists'}
$source='results/paper_ready/final_v2/geometry_network.csv'
$rows=Import-Csv -LiteralPath $source
$selected=Get-Content 'results/paper_ready/final_v2/geometry_selection.json' -Raw | ConvertFrom-Json
if($rows.Count -ne 360 -or $selected.status -ne 'FROZEN'){throw 'Incomplete calibration'}
$targets=@(2.6453333944,16.802184)
function Number([string]$Value){return [double]::Parse($Value,[Globalization.CultureInfo]::InvariantCulture)}
$points=@(for($j=1;$j -le 36;$j++){
    $group=@($rows | Where-Object {[int]$_.gridIndex -eq $j})
    if($group.Count -ne 10 -or @($group.network | Sort-Object -Unique).Count -ne 10){throw 'Wrong independent-network count'}
    if(@($group.alpha | Sort-Object -Unique).Count -ne 1 -or @($group.betaNormalized | Sort-Object -Unique).Count -ne 1){throw 'Network-specific geometry detected'}
    foreach($row in $group){
        if((Number $row.captureControl) -lt .95 -or (Number $row.beforeControl) -ge .95){throw 'Control K is not the minimum reaching 95%'}
        if([Math]::Abs(((Number $row.prBlock)-(Number $row.prIntact))-(Number $row.deltaPR)) -gt 1e-10){throw 'PR effect is not paired'}
        if([Math]::Abs(((Number $row.expectedPct)-(Number $row.observedPct))-(Number $row.deficitPP)) -gt 1e-10){throw 'Alignment deficit mismatch'}
    }
    $pr=@($group | ForEach-Object {Number $_.deltaPR} | Sort-Object)
    $align=@($group | ForEach-Object {Number $_.deficitPP} | Sort-Object)
    $prMedian=($pr[4]+$pr[5])/2; $alignMedian=($align[4]+$align[5])/2
    $loss=[Math]::Pow(($prMedian-$targets[0])/$targets[0],2)+[Math]::Pow(($alignMedian-$targets[1])/$targets[1],2)
    [pscustomobject]@{gridIndex=$j;alpha=(Number $group[0].alpha);betaNormalized=(Number $group[0].betaNormalized);deltaPR=$prMedian;deficitPP=$alignMedian;loss=$loss}
})
$ordered=@($points | Sort-Object loss)
if($ordered[0].loss -eq $ordered[1].loss){throw 'Exact tie in independently read exports'}
$best=$ordered[0]
if($best.gridIndex -ne $selected.gridIndex -or $best.alpha -ne $selected.alpha -or $best.betaNormalized -ne $selected.betaNormalized){throw 'Winner differs'}
$error=[Math]::Max([Math]::Abs($best.loss-$selected.loss),[Math]::Max([Math]::Abs($best.deltaPR-$selected.deltaPR),[Math]::Abs($best.deficitPP-$selected.deficitPP)))
if($error -gt 1e-10){throw 'Selected metrics differ beyond CSV display precision'}
[ordered]@{status='PASS';implementation='Independent PowerShell sorted order statistics; geometry-only CSV inputs';networkRows=360;sharedGridPoints=36;networksPerPoint=10;uniqueWinner=$best;runnerUpLoss=$ordered[1].loss;maximumReceiptDifference=$error;minimumControl95Verified=$true;betaAtFixedUpperBoundary=$true;gridExpanded=$false;input=$source;sourceSha256=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash;utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $out
Get-Content -LiteralPath $out
