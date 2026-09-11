$ErrorActionPreference='Stop'
$predRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$predExpected=@{
  'artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_IMPLEMENTATION_STOP.md'='6AA3BD975C883E29DF0763B4F18DA5BDB479EA723AA8A5AA019EF16BC3E1F112'
  'artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_PREFLIGHT_STOP.md'='735BD9A675C197D20846A2533732291F87F64A865B513516F9EEBE4BA0ABCDE9'
  'artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_PLAN.md'='F4004E10C76CD6B4681BBB439BE3AA96A671E5F0B3370EFC4389CFB6CEAB4272'
  'results/stage_3/current/prediction_validation/preflight.json'='F47F91B834F0A5F87E7FEFCF233BB064FBD05768F0F00FB167521BF374C448CB'
  'results/stage_3/current/prediction_validation/preflight.mat'='0775D57729949EE31C63E04F6CA16996BD1F0A2AE3AA84EB4E0CBEEE6D1D1614'
  'results/stage_3/current/cache/prediction_validation/preflight_evidence.mat'='0AB9427AC3775E5C35DDAFC083B73E9B8CACA8883DC3F88D9B095D6F12E9B8B1'
  'artifacts/manifests/stage3_cortical_state_feasibility/prediction_preflight.log'='31A2DB2CFA99963090AAB2402B77552C81BD9934DA259E1E285951E7DAC79E2D'
  'analysis/stage_3/stage3_prediction_noise.m'='7273BD6937695ABBE8B41FDA21CCE03B4EB8AD563FBBC19E43D57B6561EEE3A9'
  'analysis/stage_3/stage3_prediction_paths.m'='D1A6859918751F8C87985A0B166B85332618BEE12CE8CE37D7225B4A06A20FE4'
  'analysis/stage_3/stage3_prediction_preflight.m'='C493DEB3758D1E43682BA7437EE05F548CD8653B9ECA048EFB4F85059A512B3E'
  'results/stage_3/current/prediction_validation/code_analyzer.json'='4CA6DFD7B27864788AF3409B98E15E6A1272944C8E0E147E936618C94AC72796'
}
foreach($predEntry in $predExpected.GetEnumerator()){
  $predFile=Join-Path $predRoot $predEntry.Key
  if((Get-FileHash -LiteralPath $predFile).Hash -ne $predEntry.Value){throw "Changed prior evidence: $($predEntry.Key)"}
}
$predWrapper=Join-Path $predRoot 'analysis/stage_3/stage3_prediction_replay.m'
$predText=[Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes($predWrapper))
if(-not $predText.Contains('if nargin<8, dt=m.dt; end')){throw 'Authorized guard not present'}
$predOriginal=$predText.Replace('if nargin<8, dt=m.dt; end','if nargin<9, dt=m.dt; end')
$predRecoveredHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($predOriginal)))
if($predRecoveredHash -ne 'CB2E1EC4728CE24B46C733CEF472C5F440DE78A2B85822477AC68BE5E22D26C3'){throw 'Wrapper differs beyond the one authorized guard edit'}
& (Join-Path $PSScriptRoot 'prediction_preserve.ps1') -Verify
$predReceipt=[ordered]@{status='PASS';originalAssets=866;priorPredictionEvidence=$predExpected.Count;wrapperChange='Only nargin<9 to nargin<8';checkedUTC=[DateTime]::UtcNow.ToString('o')}
$predReceipt | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'PREDICTION_REPAIR_PRESERVATION.json') -Encoding utf8
Write-Output 'PASS: prior failed evidence and locked settings unchanged; only authorized wrapper guard differs'
