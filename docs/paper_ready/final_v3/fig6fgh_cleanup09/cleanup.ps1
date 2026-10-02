param([ValidateSet('plan','execute')][string]$Phase)
$ErrorActionPreference='Stop'
$repo09='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$docs09=Join-Path $repo09 'docs/paper_ready/final_v3/fig6fgh_cleanup09'
$manifest09=Join-Path $docs09 'cleanup_manifest.json'
Set-Location -LiteralPath $repo09
function Assert-Safe09($row09){
    $path09=[IO.Path]::GetFullPath((Join-Path $repo09 $row09.path))
    if(-not $path09.StartsWith($repo09+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Outside repository'}
    if($path09 -notlike '*\cache\*'){throw 'Not a cache file'}
    $info09=Get-Item -LiteralPath $path09 -Force
    if($info09.PSIsContainer -or ($info09.Attributes -band [IO.FileAttributes]::ReparsePoint)){throw 'Not an ordinary file'}
    if($info09.Length -ne $row09.bytes -or $info09.LastWriteTimeUtc.Ticks -ne $row09.modifiedTicks){throw "Changed candidate: $($row09.path)"}
    $parent09=$info09.Directory
    while($parent09.FullName -ne $repo09){if($parent09.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Reparse ancestor'};$parent09=$parent09.Parent}
    return $path09
}
if($Phase -eq 'plan'){
    if(Test-Path -LiteralPath $manifest09){throw 'Preserve cleanup plan'}
    $before09=Get-Content (Join-Path $docs09 'inventory_before.json') -Raw|ConvertFrom-Json
    $protected09=@{};Get-Content (Join-Path $docs09 'protected_hashes.json') -Raw|ConvertFrom-Json|ForEach-Object{$protected09[$_.path]=$true}
    $rules09=[ordered]@{
        historical_stationarity='^results/paper_ready/cache/stationary_convergence/'
        historical_convergence='^results/paper_ready/cache/convergence_reanalysis/'
        historical_postgo='^results/stage_3/current/cache/postgo_noise_diagnostic/'
        historical_stage3_prediction='^results/stage_3/current/cache/prediction_validation/n\d{2}_s[1-3]_p[1-4]\.mat$'
        historical_landscape='^results/stage_1/cache/movement_landscape_diagnostic/'
        superseded_zero_noise='^results/paper_ready/cache/final_v3/fig6ij_fivelevel/'
        superseded_noise_policies='^results/paper_ready/cache/noise_sensitivity/raw_n\d{2}_(e2_v[1-5]_p[12]|e1_v[1-5]_p2)\.mat$'
        superseded_eta_policies='^results/paper_ready/cache/stabilization_eta/raw_n\d{2}_(e[2-4]_p[12]|e5_p2)\.mat$'
    }
    $rows09=@(foreach($r09 in $before09.entries){foreach($rule09 in $rules09.GetEnumerator()){if($r09.path -match $rule09.Value){
        if($r09.tracked -or $r09.reparse -or $protected09.ContainsKey($r09.path)){throw "Protected candidate $($r09.path)"}
        $null=Assert-Safe09 $r09
        [pscustomobject]@{path=$r09.path;bytes=$r09.bytes;modifiedTicks=$r09.modifiedTicks;reason=$rule09.Key}
        break
    }}})
    $ignored09=@($rows09.path | & git check-ignore --stdin)
    if($LASTEXITCODE -ne 0 -or $ignored09.Count -ne $rows09.Count){throw 'Some candidates not ignored'}
    $groups09=@($rows09|Group-Object reason|ForEach-Object{[pscustomobject]@{reason=$_.Name;files=$_.Count;bytes=($_.Group|Measure-Object bytes -Sum).Sum}})
    $out09=[ordered]@{status='PLANNED';root=$repo09;utc=[DateTime]::UtcNow.ToString('o');files=$rows09.Count;bytes=($rows09|Measure-Object bytes -Sum).Sum;groups=$groups09;entries=$rows09}
    $out09|ConvertTo-Json -Depth 6|Set-Content -LiteralPath $manifest09 -Encoding utf8
    $groups09|Format-Table
    [pscustomobject]@{files=$out09.files;bytes=$out09.bytes}|ConvertTo-Json
}else{
    $receipt09=Join-Path $docs09 'cleanup_executed.json'
    if(Test-Path -LiteralPath $receipt09){throw 'Do not repeat cleanup'}
    $plan09=Get-Content -LiteralPath $manifest09 -Raw|ConvertFrom-Json
    $tracked09=@{};& git ls-files|ForEach-Object{$tracked09[$_]=$true}
    foreach($r09 in $plan09.entries){$null=Assert-Safe09 $r09;if($tracked09.ContainsKey($r09.path)){throw 'Candidate now tracked'}}
    $deleted09=[Collections.Generic.List[object]]::new()
    try{
        foreach($r09 in $plan09.entries){
            $path09=Assert-Safe09 $r09
            Remove-Item -LiteralPath $path09 -Force -ErrorAction Stop
            if(Test-Path -LiteralPath $path09){throw 'Deletion verification failed'}
            $deleted09.Add($r09)
        }
        $status09='PASS'
    }finally{
        [ordered]@{status=$status09;utc=[DateTime]::UtcNow.ToString('o');files=$deleted09.Count;bytes=($deleted09|Measure-Object bytes -Sum).Sum;entries=$deleted09}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath $receipt09 -Encoding utf8
    }
    [pscustomobject]@{status=$status09;files=$deleted09.Count;bytes=($deleted09|Measure-Object bytes -Sum).Sum}|ConvertTo-Json
}
