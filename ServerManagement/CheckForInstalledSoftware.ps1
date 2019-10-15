$Cred = Get-Credential
Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } -Properties OperatingSystem |

ForEach-Object {
Invoke-Command -ComputerName $_.Name -Credential $Cred -ScriptBlock {Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object DisplayName -Like "*PDF*" | 
        Select-Object DisplayName }
}