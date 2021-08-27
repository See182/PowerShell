# CSV File
# LogonName,NewLogonName
# Test1,Test.1
# Test2, Test.2
#

# Variables
$CSVPath = "C:\Test.csv"
$LogPath = "C:\Log.txt"

# Start logging
Start-Transcript -Path $LogPath

#Start Script
Import-Csv $CSVPath | ForEach-Object {
    Get-ADUser -Identity $_.LogonName | Select-Object Name, SamAccountName, Userprincipalname | Write-Host # Old Name for Log
    Get-ADUser -Identity $_.LogonName | Set-ADUser -SamAccountName $_.NewLogonName -UserPrincipalName ($_.NewLogonName + "@dold-holzwerke.com") # Change Username
    Get-ADUser -Identity $_.NewLogonName | Select-Object Name, SamAccountName, Userprincipalname | Write-Host # New Name for Log
}
# End logging
Stop-Transcript