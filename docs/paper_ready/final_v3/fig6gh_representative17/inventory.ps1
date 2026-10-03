$ErrorActionPreference='Stop'
$invRoot='E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model'
$invDocs=Join-Path $invRoot 'docs/paper_ready/final_v3/fig6gh_representative17'
$allInv=@(Get-ChildItem -LiteralPath $invRoot -Recurse -Force -File)
$groupsInv=@($allInv|Group-Object {([IO.Path]::GetRelativePath($invRoot,$_.FullName).Replace('\','/').Split('/')[0..1]-join '/')}|ForEach-Object{[pscustomobject]@{directory=$_.Name;bytes=($_.Group|Measure-Object Length -Sum).Sum;files=$_.Count}}|Sort-Object bytes -Descending|Select-Object -First 10)
$rowsInv=@($allInv|Where-Object {$_.FullName.Replace('\','/') -match '/fig6gh_representative17/'}|ForEach-Object{
    $relInv=[IO.Path]::GetRelativePath($invRoot,$_.FullName).Replace('\','/')
    $classInv='durable audit/documentation'
    if($relInv.StartsWith('analysis/')){$classInv='durable display-only code'}
    if($relInv.StartsWith('results/')){$classInv='compact display sources'}
    if($relInv.StartsWith('plots/')){$classInv='native FIG/PNG'}
    if($relInv.Contains('/cache/')){$classInv='ignored derived reproducibility cache; do not stage'}
    [pscustomobject]@{path=$relInv;bytes=$_.Length;classification=$classInv;action='retain';sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}
})
[ordered]@{status='PASS';scope='No broad cleanup. No dispensable temporary files created; zero deletions.';deletedPaths=@();reclaimedBytes=0;projectBytesIncludingGit=($allInv|Measure-Object Length -Sum).Sum;largestDirectories=$groupsInv;newFiles=$rowsInv}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath (Join-Path $invDocs 'CLEANUP_INVENTORY.json') -Encoding utf8
[pscustomobject]@{bytes=($allInv|Measure-Object Length -Sum).Sum;newFiles=$rowsInv.Count;deleted=0;largest=$groupsInv}|ConvertTo-Json -Depth 4
