$folderPath = 'D:\RDS_Standalone'
$folderPreffix = 'RDSTD'

$numberArray = @()
$numberCounter = 0..99 ; foreach ($number in $numberCounter){
    if ($number -le 9){
        $number = "0" + $number
    }
    $numberArray += $number
}

for ($i=0; $i -lt $numberArray.Length; $i++) { 
    New-Item -ItemType Directory -Path $folderPath\$($folderPreffix)$($numberArray[$i])
    $ACL = Get-Acl $folderPath\$($folderPreffix)$($numberArray[$i])
    $Owner = New-Object System.Security.Principal.Ntaccount("DOMAIN\Admin")
    $ACL.SetOwner($Owner)
    $AccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule('ERSTELLER-BESITZER','Modify', 'ContainerInherit, ObjectInherit', 'InheritOnly','Allow')
    $ACL.AddAccessRule($AccessRule1)
    $AccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule('DOMAIN\USER','Modify', 'None', 'None','Allow')
    $ACL.AddAccessRule($AccessRule2)
    $ACL | Set-Acl $folderPath\$($folderPreffix)$($numberArray[$i])
}