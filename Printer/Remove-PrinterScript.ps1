<#
    .SYNOPSIS
    Remove all network printers

    .DESCRIPTION
    This Scripts removes all network printers installed on the executed computer.

	.LINK
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

#requires -Version 2.0
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