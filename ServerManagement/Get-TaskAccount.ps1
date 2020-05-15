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
$OutFilePath = "C:\Task_Account"

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
       
        schtasks.exe /query /V /FO CSV | 
        ConvertFrom-Csv |
        Where-Object { $_."Als Benutzer ausführen" -NE "Als Benutzer ausführen" } | 
        Where-Object { $_."Als Benutzer ausführen" -NE "VORDEFINIERT\Benutzer" } | 
        Where-Object { $_."Als Benutzer ausführen" -NE "VORDEFINIERT\Administratoren" } | 
        Where-Object { $_."Als Benutzer ausführen" -NE "NT-AUTORITÄT\SYSTEM" } | 
        Where-Object { $_."Als Benutzer ausführen" -NE "NT-AUTORITÄT\Lokaler Dienst" } | 
        Where-Object { $_."Als Benutzer ausführen" -NE "NT-AUTORITÄT\INTERAKTIV" } | 
        Where-Object { $_."Als Benutzer ausführen" -NE "NT-AUTORITÄT\Authentifizierte Benutzer" } | 
        Where-Object { $_."Als Benutzer ausführen" -NE $null } | 
        Select-Object Hostname, Aufgabenname, "Als Benutzer ausführen" | Format-List
        Out-File -Encoding UTF8 -FilePath "$OutFilePath\TaskResult_$Server.txt"

        Write-Host "Creating Log for $Server" -ForegroundColor Blue -BackgroundColor Black
    } else {
        Write-Host "I $Server bims nicht da :-(" -ForegroundColor Red
    }

}