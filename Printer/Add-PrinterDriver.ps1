$PrinterServer=DDS01

$Wmi = ([wmiclass]'Win32_Printer') ; $Wmi.Scope.Options.EnablePrivileges = $true; gwmi win32_printer -ComputerName $PrinterServer -Filter 'shared=true' | foreach {$Wmi.AddPrinterConnection( [string]::Concat('\\', $_.__SERVER, '\', $_.ShareName) )}