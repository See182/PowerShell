<#
    .SYNOPSIS
    Connects Printer via Powershell based with a GPO.

    .DESCRIPTION
    This Scripts gathers the information from a GPO and connects the Printer via Powershell.

    .PARAMETER FirstParameter
    Description of each of the parameters.
    Note:
    To make it easier to keep the comments synchronized with changes to the parameters,
    the preferred location for parameter documentation comments is not here,
    but within the param block, directly above each parameter.

    .PARAMETER SecondParameter
    Description of each of the parameters.

    .INPUTS
    Description of objects that can be piped to the script.

    .OUTPUTS
    Description of objects that are output by the script.

    .EXAMPLE
    Example of how to run the script.

    .LINK
    Links to further documentation.

    .NOTES
    The GPO Feature needs to be installed on the server.

#>
# variabels
$GPOGuid = "E64E05A0-8ED7-42A4-98C4-F0447C280EEA"
$Domain = "CARITAS.local"
$LogDir="\\FIL02.caritas.local\PrinterLog$"
$LogPath="$($LogDir)\$($env:USERNAME)_$($env:COMPUTERNAME)_PrinterScript.log"

write-host "Writing logs to $($LogPath)"   
<#
    Check to see if the log directory exists and create it it doesn't yet exist.
    $LogPathExist=false
    Is the H drive already mapped
#>
    $LogPathExist=Test-Path $LogDir
    if ($logPathExist) {
        write-host "$($LogDir) Exists"
    } else {
        write-host "$($LogDir) Does not exist"
        #create directory for for logfile
        mkdir $LogDir
    }
    
<#
    Is the folder created
    create the folder if its not already there
#>
  
Start-Transcript -Path $LogPath
    
[xml]$printersXml = Get-Content "\\$Domain\sysvol\$Domain\Policies\{$GPOGuid}\User\Preferences\Printers\Printers.xml" 
$userGroups = ([Security.Principal.WindowsIdentity]"$($env:USERNAME)").Groups.Translate([System.Security.Principal.NTAccount])
$computerGroups = ([Security.Principal.WindowsIdentity]"$($env:COMPUTERNAME)").Groups.Translate([System.Security.Principal.NTAccount])

Function Process-FilterComputer {
    Param(
        $filter
    )

    $result = $false

    if ($filter.type -eq "NETBIOS") {
        if ($env:COMPUTERNAME -like $filter.name) {
        	$result = $true
        }
    }

    if ($filter.not -eq 0) {
        return $result
    }
    else {
        return !$result
    }
}
    
Function Process-FilterUser {
    Param(
        $filter
    )

    $result = $false

    if ("$env:USERDOMAIN\$env:USERNAME" -like $filter.name) {
        $result = $true
    }

    if ($filter.not -eq 0) {
        return $result
    } 
    else {
        return !$result
    }
}
    
Function Process-FilterGroup {
    Param(
        $filter
    )
    
    $result = $false
    
    if ($filter.userContext -eq 1) {
        if ($userGroups -contains $filter.name) {
            $result = $true
        }
    } else {
        if ($computerGroups -contains $filter.name) {
            $result = $true
        }
    }
    
    if ($filter.not -eq 0) {
        return $result
    } 
    else {
        return !$result
    }
}
    
Function Process-FilterCollection {
    Param(
        $filter
    )
    
    if ($filter.HasChildNodes) {
        $result = $true
        $childFilter = $filter.FirstChild
    
        while ($childFilter -ne $null) {
            if (($childFilter.bool -eq "OR") -or ($childFilter.bool -eq "AND" -and $result -eq $true)) {
                if ($childFilter.LocalName -eq "FilterComputer") {                    
                    $result = Process-FilterComputer $childFilter
                } elseif ($childFilter.LocalName -eq "FilterUser") {
                    $result = Process-FilterUser $childFilter
                } elseif ($childFilter.LocalName -eq "FilterGroup") {
                    $result = Process-FilterGroup $childFilter
                } elseif ($childFilter.LocalName -eq "FilterCollection") {
                    $result = Process-FilterCollection $childFilter
                }
    
                #Write-Host "Process-$($childFilter.LocalName) $($childFilter.name): $($result)"
            } else {
                #Write-Host "Process-$($childFilter.LocalName) $($childFilter.name): skipped"
            }
    
            if (($childFilter.NextSibling.bool -eq "OR") -and ($result -eq $true)) {
                break
            } else {
                $childFilter = $childFilter.NextSibling
            }
        }
    }
    
    if ($filter.not -eq 1) {
        return !$result
    } else {
        return $result
    }
}
    
$com = New-Object -ComObject WScript.Network
$installedPrinterDrivers = get-printerdriver
    
#Get-Content "\\$Domain\sysvol\$Domain\Policies\{$GPOGuid}\User\Preferences\Printers\Printers.xml"
    
foreach ($sharedPrinter in $printersXml.Printers.SharedPrinter) {
    $filterResult = Process-FilterCollection $sharedPrinter.Filters
    Write-Host "$($sharedPrinter.name) filters passed: $($filterResult)"
    
    if ($filterResult -eq $true) {
        if ($sharedPrinter.Properties.action -eq 'U') {
            #check to see if the driver is present on the XenAppServer
            
            $printServer = $sharedPrinter.Properties.path
            $printServer = $printServer.Split("\\")[2]
            $driverName = Get-Printer -ComputerName $($PrintServer) -Name $($sharedPrinter.name)
    
            if ($installedPrinterDrivers | where {$_.name -eq $driverName.drivername}) {
            #Create the printer in the session
                $com.AddWindowsPrinterConnection($sharedPrinter.Properties.path)
                "AddWindowsPrinterConnection:$($sharedPrinter.Properties.path)"
                if ($sharedPrinter.Properties.default -eq 1) {
                    #$com.SetDefaultPrinter($sharedPrinter.Properties.path)
                    (Get-WmiObject -ComputerName . -Class Win32_Printer -Filter "Name='$($($sharedPrinter.Properties.path) -replace "\\","\\")'").SetDefaultPrinter()
                    "SetDefaultPrinter:$($sharedPrinter.Properties.path)"
                }
            } else {
            #alert that the driver isn't present
            write-host "`r`n  The driver for $($sharedPrinter.Properties.path) doesn't appear to be present.  The driver that needs to be installed is $($driverName.drivername).  Please install this driver on the Server.  `n`r"
            }
        } elseif ($sharedPrinter.Properties.action -eq 'D') {
            $com.RemovePrinterConnection($sharedPrinter.Properties.path, $true, $true)
            "RemovePrinterConnection:$($sharedPrinter.Properties.path)"
        }
    }
}
    
Stop-Transcript