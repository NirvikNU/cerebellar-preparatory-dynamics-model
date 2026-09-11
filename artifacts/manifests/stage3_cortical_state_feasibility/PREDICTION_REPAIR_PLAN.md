# Binding fine-step repair, 2026-09-11

Authority: Agent Instructions revision 2026-09-11T01:01:59.850Z. This addendum
does not alter PREDICTION_PLAN.md or any scientific/analysis/noise parameter.
The only edit to an existing MATLAB helper is nargin<9 -> nargin<8 in
stage3_prediction_replay.m. New stage3_prediction_preflight_repair.m reuses
the preserved isolated-leak/CRN/s=0 audit and original standardized coarse
and Brownian-bridge fine noise. It computes only the original bounded
network1/targets1,5/trial1/four-policy/three-amplitude coarse/fine pairs and
dependent step, safety and event-window checks. The same paired outputs
explicitly test omitted dt=.0002 and supplied dt=.0001. No extra model run
is required for the supplied-argument test. The old files are never written.

Save separate preflight_repair.{mat,json} and ignored
preflight_repair_evidence.mat, including every completed coarse/fine pair.
Original helper SHA256 before the authorized one-line repair:
CB2E1EC4728CE24B46C733CEF472C5F440DE78A2B85822477AC68BE5E22D26C3.

Original stop/evidence/locked plan preservation SHA256:

| File | SHA256 |
| --- | --- |
| PREDICTION_IMPLEMENTATION_STOP.md | 6AA3BD975C883E29DF0763B4F18DA5BDB479EA723AA8A5AA019EF16BC3E1F112 |
| PREDICTION_PREFLIGHT_STOP.md | 735BD9A675C197D20846A2533732291F87F64A865B513516F9EEBE4BA0ABCDE9 |
| PREDICTION_PLAN.md | F4004E10C76CD6B4681BBB439BE3AA96A671E5F0B3370EFC4389CFB6CEAB4272 |
| preflight.json | F47F91B834F0A5F87E7FEFCF233BB064FBD05768F0F00FB167521BF374C448CB |
| preflight.mat | 0775D57729949EE31C63E04F6CA16996BD1F0A2AE3AA84EB4E0CBEEE6D1D1614 |
| preflight_evidence.mat | 0AB9427AC3775E5C35DDAFC083B73E9B8CACA8883DC3F88D9B095D6F12E9B8B1 |
| prediction_preflight.log | 31A2DB2CFA99963090AAB2402B77552C81BD9934DA259E1E285951E7DAC79E2D |

Git-health/fetch/direct-remote preflight passed at the required c40e0eb
checkpoint; dirty files match the 12-file stopped inventory. All 866 original
baseline hashes were verified unchanged before the repaired preflight.
Current Main_text_v8 retains its 2026-09-10T15:57:38.963Z revision.
If this bounded check passes, resume the unchanged locked production and
analysis. On a new failure, preserve evidence and stop without tuning.
