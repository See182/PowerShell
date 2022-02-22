$String = "Set-GPUserCSE"
$Path = 'D:\temp'

Get-ChildItem -Path $Path -Recurse | Select-String -Pattern $String