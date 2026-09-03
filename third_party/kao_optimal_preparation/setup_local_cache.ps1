[CmdletBinding()]
param(
    [string]$ExistingCacheRoot,
    [string]$NativeArchive
)

$ErrorActionPreference = 'Stop'
$metadataRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$cacheRoot = Join-Path $metadataRoot 'local_cache'
$sourceRoot = Join-Path $cacheRoot 'kao_optimal_preparation'
$commit = '40077d2da16e68ab2ab2cff59ec692b97315980b'
$upstream = 'https://github.com/hennequin-lab/optimal-preparation.git'

if (Test-Path -LiteralPath $cacheRoot) {
    $payload = Get-ChildItem -LiteralPath $cacheRoot -Force |
        Where-Object { $_.Name -ine 'desktop.ini' }
    if ($payload) {
        throw "Local cache already contains payloads: $cacheRoot"
    }
} else {
    New-Item -ItemType Directory -Path $cacheRoot | Out-Null
}

if ($ExistingCacheRoot) {
    $resolved = (Resolve-Path -LiteralPath $ExistingCacheRoot).Path
    $required = @('kao_optimal_preparation')
    foreach ($name in $required) {
        $source = Join-Path $resolved $name
        if (-not (Test-Path -LiteralPath $source -PathType Container)) {
            throw "Existing cache is missing $name under $resolved"
        }
        Copy-Item -LiteralPath $source -Destination $cacheRoot -Recurse
    }
} else {
    git clone $upstream $sourceRoot
    if ($LASTEXITCODE -ne 0) { throw 'Upstream clone failed.' }
    git -C $sourceRoot checkout --detach $commit
    if ($LASTEXITCODE -ne 0) { throw 'Pinned checkout failed.' }
}

$nativeRoot = Join-Path $sourceRoot 'native_reference_40077d2'
if ($NativeArchive) {
    $archive = (Resolve-Path -LiteralPath $NativeArchive).Path
    $expected = '339172D55FF2B3395673E8605859553A3A55C6C61A7C8B32A2B4850EC53EC6B7'
    $actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
    if ($actual -ne $expected) { throw 'Native-reference archive hash mismatch.' }
    tar -xzf $archive -C $sourceRoot
    if ($LASTEXITCODE -ne 0) { throw 'Native-reference archive extraction failed.' }
}

if (-not (Test-Path -LiteralPath $nativeRoot -PathType Container)) {
    throw @"
Pinned source acquired, but the generated native reference is absent.
Provide the verified archive with -NativeArchive or reproduce it following
NATIVE_REFERENCE_REPRODUCTION.md. No historical-result fallback is permitted.
"@
}

& (Join-Path $metadataRoot 'verify_local_cache.ps1')
