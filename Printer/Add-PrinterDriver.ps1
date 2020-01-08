# Install all Printers from the PrintServer
$PrintServer = "DDS01"

$Wmi = ([wmiclass]'Win32_Printer') ; $Wmi.Scope.Options.EnablePrivileges = $true; gwmi win32_printer -ComputerName $PrintServer -Filter 'shared=true' | foreach {$Wmi.AddPrinterConnection( [string]::Concat('\\', $_.__SERVER, '\', $_.ShareName) )}

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