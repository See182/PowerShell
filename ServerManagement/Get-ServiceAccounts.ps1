<#
    .SYNOPSIS
    Check Services on Servers

    .DESCRIPTION
    This Scripts gathers custom accounts for Windows Services from different Remote Servers. Userful if you want to know if you are using any custom accounts to start/stop services

    .EXAMPLE


    .LINK


    .NOTES
    
#>
#   Variabeln   #

$ServerList = Get-Content ".\Servers.txt"
$OutFilePath = "C:\Service_Account"

#   Script  #
# Checking if everything is there
if (Test-Path $OutFilePath) {
    Write-Host "$OutFilePath is there." -ForegroundColor Green
} else {
    Write-Host "$OutFilePath is not there, we have to create it..."
    mkdir $OutFilePath
}

ForEach ($Server in $ServerList) {

    $Ping = Test-Connection -Quiet -Count 1 -ComputerName $Server

    if ($Ping -eq "True") {
        Write-Host "I $Server bims da" -ForegroundColor Green 
        Get-WmiObject -Class Win32_Service -ComputerName $Server | Where-Object StartName -NE "LocalSystem" | Where-Object StartName -NE "NT AUTHORITY\LocalService" | Where-Object StartName -NE "NT AUTHORITY\NetworkService" | Where-Object StartName -NE $null |  Select-Object Displayname, Name, Startname | Out-File -Encoding utf8 -FilePath "$OutFilePath\ServiceResult_$Server.txt"

        Write-Host "Creating Log for $Server" -ForegroundColor Blue -BackgroundColor Black
    } else {
        Write-Host "I $Server bims nicht da :-(" -ForegroundColor Red
    }

}