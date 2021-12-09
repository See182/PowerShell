$Users = Get-Content "C:\Users.txt"
ForEach ($user in $users)
{
$newPath = Join-Path "\\myserver\Users$" -childpath $user
New-Item $newPath -type directory

$acl = Get-Acl $newpath
$permission = "mydomain\$user","FullControl","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
$acl | Set-Acl $newpath
}