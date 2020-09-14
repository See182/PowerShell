<#
    .SYNOPSIS
    Connects printer via PowerShell based on a GPO. Replaces the deployment of printers via GPOs.

    .DESCRIPTION
    This Scripts gathers the information from a GPO and connects the Printer via Powershell. Can be used during logon.

    .COMPONENT
    Create a GPO with printers installed under User -> Policy -> Control Panel Settings -> Printer. Script uses the created XML file to gather its needed information.

    .LINK
    Script is based on script created by Preston Gallwas
    https://www.atumvirt.com/2013/11/dramatically-reducing-logon-time-to-desktop-by-moving-from-group-policy-preferences-to-powershell-logon-script/ https://www.atumvirt.com/2013/11/dramatically-reducing-logon-time-to-desktop-by-moving-from-group-policy-preferences-to-powershell-logon-script/ 

    .NOTES
    ▄▀▀ ▄▀▄ █▄ █ ▄▀▀ ▄▀▄ ▀█▀   ▄▀▄ ▄▀ 
    ▀▄▄ ▀▄▀ █ ▀█ ▀▄▄ █▀█  █    █▀█ ▀▄█
    Author: Steve Kirby
    Country: Germany
    Released Date (DD/MM/YYYY): 14/09/2020
    Gitlab Link:
#>

# Variabels
$GPOGuid = "E64E05A0-8ED7-42A4-98C4-F0447C280EEA"
$Domain = "DOMAIN.local"
$LogDir="\\FILESERVER\PrinterLog$"
$LogPath="$($LogDir)\$($env:USERNAME)_$($env:COMPUTERNAME)_PrinterScript.log"

# Check to see if the log directory exists.
write-host "Writing logs to $($LogPath)"
$LogPathExist=Test-Path $LogDir
if ($logPathExist) {
    write-host "$($LogDir) Exists"
} else {
    # Changes the LogDirectory to a local Folder 
    write-host "$($LogDir) Does not exist fallback to a local dir"
    $LogDir="C:\PrintLog"
    mkdir $LogDir
}

# Start logging
Start-Transcript -Path $LogPath
# Variabels    
[xml]$printersXml = Get-Content "\\$Domain\sysvol\$Domain\Policies\{$GPOGuid}\User\Preferences\Printers\Printers.xml" 
$userGroups = ([Security.Principal.WindowsIdentity]"$($env:USERNAME)").Groups.Translate([System.Security.Principal.NTAccount])
$computerGroups = ([Security.Principal.WindowsIdentity]"$($env:COMPUTERNAME)").Groups.Translate([System.Security.Principal.NTAccount])

# Functions
Function Get-FilterComputer {
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
    
Function Get-FilterUser {
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
    
Function Get-FilterGroup {
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
    
Function Get-FilterCollection {
    Param(
        $filter
    )
    
    if ($filter.HasChildNodes) {
        $result = $true
        $childFilter = $filter.FirstChild
    
        while ($null -ne $childFilter) {
            if (($childFilter.bool -eq "OR") -or ($childFilter.bool -eq "AND" -and $result -eq $true)) {
                if ($childFilter.LocalName -eq "FilterComputer") {                    
                    $result = Get-FilterComputer $childFilter
                } elseif ($childFilter.LocalName -eq "FilterUser") {
                    $result = Get-FilterUser $childFilter
                } elseif ($childFilter.LocalName -eq "FilterGroup") {
                    $result = Get-FilterGroup $childFilter
                } elseif ($childFilter.LocalName -eq "FilterCollection") {
                    $result = Get-FilterCollection $childFilter
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

# Installing Script
$com = New-Object -ComObject WScript.Network
$installedPrinterDrivers = Get-PrinterDriver
    
#Get-Content "\\$Domain\sysvol\$Domain\Policies\{$GPOGuid}\User\Preferences\Printers\Printers.xml"
    
foreach ($sharedPrinter in $printersXml.Printers.SharedPrinter) {
    $filterResult = Get-FilterCollection $sharedPrinter.Filters
    Write-Host "$($sharedPrinter.name) filters passed: $($filterResult)"
    
    if ($filterResult -eq $true) {
        if ($sharedPrinter.Properties.action -eq 'U') {
            #check to see if the driver is present on the Server
            
            $printServer = $sharedPrinter.Properties.path
            $printServer = $printServer.Split("\\")[2]
            $driverName = Get-Printer -ComputerName $($PrintServer) -Name $($sharedPrinter.name)
    
            if ($installedPrinterDrivers | Where-Object {$_.name -eq $driverName.drivername}) {
            #Create the printer in the session
                $com.AddWindowsPrinterConnection($sharedPrinter.Properties.path)
                "AddWindowsPrinterConnection:$($sharedPrinter.Properties.path)"
                if ($sharedPrinter.Properties.default -eq 1) {
                    #$com.SetDefaultPrinter($sharedPrinter.Properties.path)
                    (Get-WmiObject -ComputerName . -Class Win32_Printer -Filter "Name='$($($sharedPrinter.Properties.path) -replace "\\","\\")'").SetDefaultPrinter()
                    "SetDefaultPrinter:$($sharedPrinter.Properties.path)"
                }
            } else {
            # install printer driver
            write-host "`r`n  The driver for $($sharedPrinter.Properties.path) doesn't appear to be present.  The driver $($driverName.drivername) will be installed. `n`r"    
            rundll32 printui.dll PrintUIEntry /in /n $sharedPrinter.Properties.path     
            #alert that the driver isn't present
            #write-host "`r`n  The driver for $($sharedPrinter.Properties.path) doesn't appear to be present.  The driver that needs to be installed is $($driverName.drivername).  Please install this driver on the Server.  `n`r"
            }
        } elseif ($sharedPrinter.Properties.action -eq 'D') {
            $com.RemovePrinterConnection($sharedPrinter.Properties.path, $true, $true)
            "RemovePrinterConnection:$($sharedPrinter.Properties.path)"
        }
    }
}

# End logging
Stop-Transcript