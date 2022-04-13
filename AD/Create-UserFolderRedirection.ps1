$User = Get-AdUser -Identity steve.kirby
$Share = "C:\FolderRedirection"
$UserFolder = "$Share\$User"


if (-Not (Test-Path $UserFolder)) {
    #Write-Host "No user folder on share, I'll create one..."
    New-Item -ItemType Directory -Path $UserFolder
    #Write-Host "Create ACL"
    #Write-Host "Setting Owner"
    $ACL = Get-Acl $UserFolder
    $Owner = New-Object System.Security.Principal.Ntaccount("BEHFPS004\Administrators")
    $ACL.SetOwner($Owner)
    #Write-Host "Setting Administrator ACL"
    $AccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule('BEHFPS004\Administrators', 'FullControl', 'None', 'None', 'Allow')
    $ACL.AddAccessRule($AccessRule1)
    #Write-Host "Setting User ACL"
    $AccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule ('CONCAT.DE\$User', 'FullControl', 'None', 'None', 'Allow')
    $ACL.AddAccessRule($AccessRule2)

    $ACL | Set-Acl $UserFolder
}