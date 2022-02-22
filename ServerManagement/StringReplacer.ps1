$FindString = 'Get-GPUserCSE'
$ReplaceString = 'Set-GPUserCSE'
$Path = 'D:\temp'

Get-ChildItem -Path $Path -Recurse | ForEach-Object{
    $file = $_.FullName
    (Get-Content $file) -replace $FindString, $ReplaceString | Set-Content $file
}