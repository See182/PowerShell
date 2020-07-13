<#
    .SYNOPSIS

    .DESCRIPTION
    This Scripts gathers the Folder names and checks if a User is connected with its Share. Results are written in a TXT File.

    .EXAMPLE
    Edit the variabels and run the script as administrator.

    .LINK
    Script is located in my Github Respo, idea came from:
    https://serverfault.com/questions/110791/find-users-connected-to-a-network-share

    .NOTES
    
#>

#Variabel
$UserFolderPath = "D:\Users"
$SourceComputerName = "localhost"
$LogFilePath = "C:\Log\UserShareLog.txt"

#Skript
$array = Get-ChildItem $UserFolderPath | Select-Object -ExpandProperty Name

foreach ($User in $array) {

    Get-WmiObject -ComputerName $SourceComputerName Win32_ServerConnection | Where-Object {$_.Sharename -EQ "$User$" } | Select-Object Username, Sharename, Computername | Out-File -Append -FilePath $LogFilePath

}