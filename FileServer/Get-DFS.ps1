<#
    .SYNOPSIS
    Connects Printer via Powershell based with a GPO.

    .DESCRIPTION
    This Scripts gathers the information from a GPO and connects the Printer via Powershell.

    .EXAMPLE
    Create a GPO with printers installed under User -> Policy -> Control Panel Settings -> Printer

    .LINK
    Script is based on script created by Preston Gallwas
    https://www.atumvirt.com/2013/11/dramatically-reducing-logon-time-to-desktop-by-moving-from-group-policy-preferences-to-powershell-logon-script/ 

    .NOTES
    
#>

#Variabel
$Domain = Read-Host -Prompt 'Domain'


