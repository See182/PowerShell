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
$UserAccount = Read-Host "Type in Domain\Username..."
$LogFolder = "C:\Log"
$ServerList = Get-Content ".\Servers.txt"
$LogFileDate = Get-Date -Format "ddMMyyy_HH_mm"

#   Script  #
if (Test-Path $LogFolder) {
    Write-Host "$LogFolder exists" -ForegroundColor Green
} else {
    Write-Host "Creating $LogFolder..."
    mkdir $LogFolder
}

ForEach ($Server in $ServerList) {
    $Ping = Test-Connection -Quiet -Count 1 -ComputerName $Server

    if ($Ping -eq "True") {
        Write-Host "$Server is reachable" -ForegroundColor Green
        Write-Host "Writing Log for $Server" -ForegroundColor Blue -BackgroundColor White

        Get-WmiObject -Class Win32_Service -ComputerName $Server | 
        Where-Object StartName -EQ $UserAccount |
        Select-Object PSComputerName, Displayname, Name | 
        Out-File -Encoding utf8 -FilePath "$LogFolder\MSService_$LogFileDate.txt" -Append

    } else {
        Write-Host "$Server is not reachable" -ForegroundColor Red
    }
}