$String = 'Get-GPUserCSE'
$Path = 'D:\temp'

Get-ChildItem -Path $Path -Recurse | Select-String -Pattern $String