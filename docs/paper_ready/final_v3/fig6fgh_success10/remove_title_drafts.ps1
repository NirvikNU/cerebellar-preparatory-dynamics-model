$ErrorActionPreference='Stop'
$taskRoot='E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model'
$taskDocs=Join-Path $taskRoot 'docs/paper_ready/final_v3/fig6fgh_success10'
$taskDrafts=[IO.Path]::GetFullPath((Join-Path $taskDocs 'local_title_drafts'))
if(-not $taskDrafts.StartsWith($taskRoot+[IO.Path]::DirectorySeparatorChar)){throw 'Draft directory outside repository'}
$taskRecords=@(foreach($taskPanel in @('f','g','h')){foreach($taskExt in @('fig','png')){
    $taskFile=(Resolve-Path -LiteralPath (Join-Path $taskDrafts "Fig6$taskPanel.$taskExt")).Path
    if(-not $taskFile.StartsWith($taskDrafts+[IO.Path]::DirectorySeparatorChar)){throw 'Path outside exact draft directory'}
    $taskItem=Get-Item -LiteralPath $taskFile
    if($taskItem.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Unexpected reparse point'}
    if(@(& git -C $taskRoot ls-files -- ([IO.Path]::GetRelativePath($taskRoot,$taskFile))).Count){throw 'Refuse tracked file deletion'}
    [pscustomobject]@{path=$taskFile;bytes=$taskItem.Length;sha256=(Get-FileHash -LiteralPath $taskFile -Algorithm SHA256).Hash;reason='New-revision preliminary title layout only; final source-identical panels validated and retained'}
}})
$taskManifest=Join-Path $taskDocs 'temporary_deletions.json'
if(Test-Path -LiteralPath $taskManifest){throw 'Refuse to replace existing deletion receipt'}
$taskRecords|ConvertTo-Json -Depth 4|Set-Content -LiteralPath $taskManifest -Encoding utf8
foreach($taskRecord in $taskRecords){
    if((Get-FileHash -LiteralPath $taskRecord.path -Algorithm SHA256).Hash -ne $taskRecord.sha256){throw 'Draft changed before deletion'}
    Remove-Item -LiteralPath $taskRecord.path -ErrorAction Stop
}
if(@(Get-ChildItem -LiteralPath $taskDrafts -Force).Count -ne 0){throw 'Unexpected remaining draft content'}
Remove-Item -LiteralPath $taskDrafts -ErrorAction Stop
[pscustomobject]@{removedFiles=$taskRecords.Count;bytes=($taskRecords|Measure-Object bytes -Sum).Sum;preexistingFilesRemoved=0}|ConvertTo-Json
