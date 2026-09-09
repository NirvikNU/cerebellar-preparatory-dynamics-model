$ErrorActionPreference='Stop'
$organizeRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$organizeResult=Get-Content -LiteralPath (Join-Path $organizeRoot 'results/stage_3/current/gain_time/summary.json') -Raw | ConvertFrom-Json
if ($organizeResult.status -ne 'PASS') { throw 'Diagnostic validation required before organization.' }
$organizeReceipt=Join-Path $PSScriptRoot 'GAIN_TIME_ROOT_ORGANIZATION.csv'
if (Test-Path -LiteralPath $organizeReceipt) { throw 'Organization already recorded; do not repeat.' }
$organizeBefore=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'GAIN_TIME_ROOT_BEFORE.csv')
$organizeHashes=Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'GAIN_TIME_INPUTS_BEFORE.csv')
$organizeLogs=Join-Path $PSScriptRoot 'execution_logs'
if (-not (Test-Path -LiteralPath $organizeLogs)) { New-Item -ItemType Directory -Path $organizeLogs | Out-Null }
$organizeRows=foreach($organizeItem in $organizeBefore) {
    $name=$organizeItem.Name; $category=''; $action='retain'; $destination=$name; $reason=''
    switch -Regex ($name) {
        '^\.git(ignore)?$' { $category='required root-level repository infrastructure'; $reason='Canonical repository metadata'; break }
        '^(AGENTS|README|MODEL_SPEC|THIRD_PARTY_PROVENANCE)\.md$' { $category='documentation'; $reason='Canonical project-level documentation'; break }
        '^run_.*\.m$' { $category='required root-level entry point'; $reason='Existing documented public runner; moving reduces clarity'; break }
        '^config$' { $category='configuration'; $reason='Established configuration directory'; break }
        '^(src|workflows)$' { $category='source/model code'; $reason='Maintained source/construction and diagnostic workflows'; break }
        '^analysis$' { $category='analysis/validation'; $reason='Established analysis and tests'; break }
        '^figures$' { $category='plotting'; $reason='Established renderer/style helpers'; break }
        '^(results|plots)$' { $category='generated result'; $reason='Accepted results/figures and reproducibility-critical caches retained'; break }
        '^artifacts$' { $category='provenance/audit artifact'; $reason='Established manifests and reports'; break }
        '^third_party$' { $category='cache/dependency source'; $reason='Pinned dependency and local-only reference cache; untouched'; break }
        '^stage3_.*\.log$' {
            $path=(Resolve-Path -LiteralPath (Join-Path $organizeRoot $name)).Path
            if ([IO.Path]::GetDirectoryName($path) -ne $organizeRoot) { throw 'Log is outside root' }
            $saved=@($organizeHashes | Where-Object { $_.path -eq $name }); if ($saved.Count -ne 1) { throw 'Missing unique log hash' }
            if ((Get-FileHash -LiteralPath $path).Hash -ne $saved[0].sha256) { throw 'Log changed since inventory' }
            if ((Get-Item -LiteralPath $path).Length -eq 0) {
                $category='stale/temporary material'; $action='delete'; $destination='none'; $reason='Zero-byte scratch execution log; no evidence content'
                Remove-Item -LiteralPath $path
                if (Test-Path -LiteralPath $path) { throw 'Empty scratch log removal failed' }
            } else {
                $category='provenance/audit artifact'; $action='move'; $reason='Preserve historical execution evidence outside sparse root'
                $target=Join-Path $organizeLogs $name
                if (Test-Path -LiteralPath $target) { throw 'Destination already exists' }
                Move-Item -LiteralPath $path -Destination $target
                if ((Get-FileHash -LiteralPath $target).Hash -ne $saved[0].sha256) { throw 'Moved log hash mismatch' }
                $destination=$target.Substring($organizeRoot.Length+1)
            }
            break
        }
        default { throw ('Unclassified root item: '+$name) }
    }
    [pscustomobject]@{before=$name;category=$category;action=$action;after=$destination;reason=$reason}
}
$organizeRows | Export-Csv -LiteralPath $organizeReceipt -NoTypeInformation
$organizeRows | Group-Object action | Select-Object Name,Count | ConvertTo-Json
