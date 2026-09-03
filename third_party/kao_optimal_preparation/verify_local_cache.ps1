[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$metadataRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$cacheRoot = Join-Path $metadataRoot 'local_cache'
$sourceRoot = Join-Path $cacheRoot 'kao_optimal_preparation'
$nativeRoot = Join-Path $sourceRoot 'native_reference_40077d2'
$expectedCommit = '40077d2da16e68ab2ab2cff59ec692b97315980b'

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Missing local Kao cache. Run $metadataRoot\setup_local_cache.ps1"
}

$head = (git -C $sourceRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $head -ne $expectedCommit) {
    throw "Kao source HEAD mismatch: expected $expectedCommit; found $head"
}

$requiredManifest = Join-Path $metadataRoot 'REQUIRED_FILES.sha256'
foreach ($line in Get-Content -LiteralPath $requiredManifest) {
    if (-not $line.Trim()) { continue }
    $parts = $line -split '\s{2,}', 2
    $path = Join-Path $cacheRoot ($parts[1] -replace '/', '\')
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required Kao file missing: $($parts[1])"
    }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    if ($actual -ne $parts[0]) { throw "Checksum mismatch: $($parts[1])" }
}

$nativeManifest = Import-Csv -LiteralPath (
    Join-Path $metadataRoot 'native_reference_manifest.tsv') -Delimiter "`t"
$byteCount = 0L
foreach ($entry in $nativeManifest) {
    $path = Join-Path $nativeRoot ($entry.relative_path -replace '/', '\')
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Native-reference file missing: $($entry.relative_path)"
    }
    $item = Get-Item -LiteralPath $path
    if ($item.Length -ne [long]$entry.bytes) {
        throw "Native-reference byte mismatch: $($entry.relative_path)"
    }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    if ($actual -ne $entry.sha256.ToUpper()) {
        throw "Native-reference checksum mismatch: $($entry.relative_path)"
    }
    $byteCount += $item.Length
}

if ($nativeManifest.Count -ne 167 -or $byteCount -ne 32508468) {
    throw 'Native-reference inventory count or byte total mismatch.'
}

Write-Output "PASS: pinned Kao commit $head"
Write-Output "PASS: $($nativeManifest.Count) native files; $byteCount bytes"
