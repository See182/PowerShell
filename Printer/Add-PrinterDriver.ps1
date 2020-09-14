<#
    .SYNOPSIS
    Install all printer from a printer server.

    .DESCRIPTION
    Install all printers including the drivers from a specific printer server. Removes all printers after the installation to keep the Server clean, drivers still stay installed.

    .LINK
    Script is based on script created by Remko Weijnen
	https://www.remkoweijnen.nl/blog/2011/01/25/script-to-install-all-print-drivers-on-citrix-or-terminal-server/
	Script is based on a script created by Reddit User DrivenDemon
	https://www.reddit.com/r/PowerShell/comments/8klbc3/delete_local_printers_from_remote_computers/

    .NOTES
    ▄▀▀ ▄▀▄ █▄ █ ▄▀▀ ▄▀▄ ▀█▀   ▄▀▄ ▄▀ 
    ▀▄▄ ▀▄▀ █ ▀█ ▀▄▄ █▀█  █    █▀█ ▀▄█
    Author: Steve Kirby
    Country: Germany
    Released Date (DD/MM/YYYY): 14/09/2020
    Gitlab Link:
#>

# Install all Printers from the PrintServer
$PrintServer = "PRINTSERVER"

$Wmi = ([wmiclass]'Win32_Printer') ; $Wmi.Scope.Options.EnablePrivileges = $true; Get-WmiObject win32_printer -ComputerName $PrintServer -Filter 'shared=true' | ForEach-Object {$Wmi.AddPrinterConnection( [string]::Concat('\\', $_.__SERVER, '\', $_.ShareName) )}

# Remove all installed network Printers
Function Remove-OSCNetworkPrinters
{
	$NetworkPrinters = Get-WmiObject -Class Win32_Printer | Where-Object{$_.Network}
	If ($null -ne $NetworkPrinters)
	{
		Try
		{
			Foreach($NetworkPrinter in $NetworkPrinters)
			{
				$NetworkPrinter.Delete()
				Write-Host "Successfully deleted the network printer:" + $NetworkPrinter.Name -ForegroundColor Green	
			}
		}
		Catch
		{
			Write-Host $_
		}
	}
	Else
	{
		Write-Warning "Cannot find network printer in the currently environment."
	}
}

Remove-OSCNetworkPrinters