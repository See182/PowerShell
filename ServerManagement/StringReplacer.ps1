$FindString = 'Get-GPUserCSE'
$ReplaceString = 'Set-GPUserCSE'
$Path = 'D:\temp'

Get-ChildItem -Path $Path -Recurse | Replace($FindString, $ReplaceString)