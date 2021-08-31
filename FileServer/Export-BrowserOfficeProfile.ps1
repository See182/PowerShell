<#
    .SYNOPSIS
    Synchronize Microsoft Internet Explorer/Edge, Google Chrome, Mozilla Firefox and Office 365 Settings and Profiles.

    .DESCRIPTION
    Synchronizes all Settings and Profiles from local drive to a network drive. Apps included are Microsoft Internet Explorer/Edge, Google Chrome, Mozilla Firefox and Office 365. Local Computer --> Server

    .NOTES
    ▄▀▀ ▄▀▄ █▄ █ ▄▀▀ ▄▀▄ ▀█▀   ▄▀▄ ▄▀
    ▀▄▄ ▀▄▀ █ ▀█ ▀▄▄ █▀█  █    █▀█ ▀▄█
    Author: Steve Kirby
    Country: Germany
    Released Date (DD/MM/YYYY): 30/08/2021
    Tested with:    Microsoft Windows 10 Enterprise 20H2 Build
                    Microsoft Internet Explorer 11
                    Microsoft Edge 92.0.902.84 (64-Bit)
                    Microsoft Office 365 Apps for Enterprise Version 2107
                    Google Chrome 92.0.4515.159 (64-Bit)
                    Mozilla Firefox 91.0.2 (64-Bit)

#>

<#~~~~~~~~~~Variables                        ~~~~~~~~~~#>
$ServerPath = "\\hh.hansemerkur.de\global\Benutzer\Einstellung\%USERNAME%"

# Mainfolders
$InternetExplorerFolder = "IE"
$EdgeFolder = "Edge"
$ChromeFolder = "Chrome"
$FirefoxFolder = "Firefox"
$OfficeFolder = "Office"

# Subfolders
$InternetExplorerFavorites = "Favorites"
$InternetExplorerHistory = "History"

$OutlookSignatures = "Signatures"
$OutlookDictionary = "Dictionary"
$OutlookTemplates = "Templates"
$OutlookAutoCorrectionLists = "AutoCorrectionLists"
$OutlookRulesXML = "RulesXML"
$OutlookOfficeUI = "OfficeUI"

<#~~~~~~~~~~Do not Edit                      ~~~~~~~~~~#>
<#~~~~~~~~~~ServerPath Check                 ~~~~~~~~~~#>
# Check to see if the Server Path directory exists.
Write-Host "Checking Server Path Variable: $($ServerPath)"
$ServerPathTest = Test-Path $ServerPath
if ($ServerPathTest) {
    Write-Host "$($ServerPath) exists"
}
else {
    Write-Warning "$($ServerPath) does not exist. Check the network or the variabel on line 24."
    Exit
}


<##~~~~~~~~~Microsoft Internet Explorer      ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$InternetExplorerFavoritesLocalPath = "C:\Users\$($env:USERNAME)\Favorites\"
$InternetExplorerHistoryLocalPath = "C:\Users\$($env:USERNAME)\AppData\Local\Microsoft\Windows\History"

<###~~~~~~~~Script                           ~~~~~~~~###>
# Copy Internet Explorer Favorites to the ServerPath
Robocopy.exe "$InternetExplorerFavoritesLocalPath" "$($ServerPath)\$($InternetExplorerFolder)\$($InternetExplorerFavorites)" /MIR /NFL /NDL /NJH /NJS /nc /ns /np

# Copy Internet Explorer History to the ServerPath
Robocopy.exe "$InternetExplorerHistoryLocalPath" "$($ServerPath)\$($InternetExplorerFolder)\$($InternetExplorerHistory)" /MIR /NFL /NDL /NJH /NJS /nc /ns /np


<##~~~~~~~~~Microsoft Edge                   ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$EdgeProfile = "C:\Users\$($env:USERNAME)\AppData\Local\Microsoft\Edge\User Data\Default"

<###~~~~~~~~Script                           ~~~~~~~~###>
Write-Host "Are we using Edge?"
if (Test-Path $EdgeProfile) {
    Write-Host "We are using Edge"
    if (-Not (Test-Path "$($ServerPath)\$($EdgeFolder)\")) {
        Write-Host "No Edge Folder in Server Path, I'll create one..."
        New-Item -ItemType Directory -Path "$($ServerPath)\$($EdgeFolder)\"
    }
    Copy-Item -Path "$EdgeProfile\Bookmarks" -Destination "$($ServerPath)\$($EdgeFolder)\" -Force
    Copy-Item -Path "$EdgeProfile\History" -Destination "$($ServerPath)\$($EdgeFolder)\" -Force
    Copy-Item -Path "$EdgeProfile\Favicons" -Destination "$($ServerPath)\$($EdgeFolder)\" -Force
    Copy-Item -Path "$EdgeProfile\Preferences" -Destination "$($ServerPath)\$($EdgeFolder)\" -Force
}
else {
    Write-Host "We are not using Edge"
}


<##~~~~~~~~~Google Chrome                    ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$ChromeProfile = "C:\Users\$($env:USERNAME)\AppData\Local\Google\Chrome\User Data\Default"

<###~~~~~~~~Script                           ~~~~~~~~###>
Write-Host "Are we using Chrome?"
if (Test-Path $ChromeProfile) {
    Write-Host "We are using Chrome"
    if (-Not (Test-Path "$($ServerPath)\$($ChromeFolder)")) {
        Write-Host "No Chrome Folder in Server Path, I'll create one..."
        New-Item -ItemType Directory -Path "$($ServerPath)\$($ChromeFolder)"
    }
    Copy-Item -Path "$ChromeProfile\Bookmarks" -Destination "$($ServerPath)\$($ChromeFolder)" -Force
    Copy-Item -Path "$ChromeProfile\History" -Destination "$($ServerPath)\$($ChromeFolder)" -Force
    Copy-Item -Path "$ChromeProfile\Favicons" -Destination "$($ServerPath)\$($ChromeFolder)" -Force
    Copy-Item -Path "$ChromeProfile\Preferences" -Destination "$($ServerPath)\$($ChromeFolder)" -Force
}
else {
    Write-Host "We are not using Chrome"
}


<##~~~~~~~~~Mozilla Firefox                  ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$FireFoxProfile = "C:\Users\$($env:USERNAME)\AppData\Roaming\Mozilla\Firefox"

<###~~~~~~~~Script                           ~~~~~~~~###>
Write-Host "Are we using Firefox?"
if (Test-Path $FirefoxProfile) {
    Write-Host "We are using Firefox"
    Robocopy.exe "$FireFoxProfile" "$($ServerPath)\$($FirefoxFolder)" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
}
else {
    Write-Host "We are not using Firefox"
}


<##~~~~~~~~~Office & Outlook                 ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$OutlookProfile = "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft"
$OutlookPath = "C:\Users\$($env:USERNAME)\AppData\Local\Microsoft\Office"

<###~~~~~~~~Script                           ~~~~~~~~###>
Write-Host "Are we using Office?"
if (Test-Path $OutlookProfile) {
    Write-Host "We are using Office"
    Robocopy.exe "$($OutlookProfile)\Signatures\" "$($ServerPath)\$($OfficeFolder)\$($OutlookSignatures)" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
    Robocopy.exe "$($OutlookProfile)\UProof\" "$($ServerPath)\$($OfficeFolder)\$($OutlookDictionary)" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
    Robocopy.exe "$($OutlookProfile)\Templates\" "$($ServerPath)\$($OfficeFolder)\$($OutlookTemplates)" /MIR /NFL /NDL /NJH /NJS /nc /ns /np

    if (-Not (Test-Path "$($ServerPath)\$($OfficeFolder)\$($OutlookAutoCorrectionLists)\")) {
        Write-Host "No Outlook Auto Corrections Lists Folder in Server Path, I'll create one..."
        New-Item -ItemType Directory -Path "$($ServerPath)\$($OfficeFolder)\$($OutlookAutoCorrectionLists)\"
    }
    Copy-Item -Path "$($OutlookProfile)\Office\*.acl" -Destination "$($ServerPath)\$($OfficeFolder)\$($OutlookAutoCorrectionLists)\" -Force

    if (-Not (Test-Path "$($ServerPath)\$($OfficeFolder)\$($OutlookRulesXML)\")) {
        Write-Host "No Outlook Rules XML Folder in Server Path, I'll create one..."
        New-Item -ItemType Directory -Path "$($ServerPath)\$($OfficeFolder)\$($OutlookRulesXML)\"
    }
    Copy-Item -Path "$($OutlookPath)\16.0\outlook.exe_Rules.xml" -Destination "$($ServerPath)\$($OfficeFolder)\$($OutlookRulesXML)\" -Force

    if (-Not (Test-Path "$($ServerPath)\$($OfficeFolder)\$($OutlookOfficeUI)\")) {
        Write-Host "No Office UI Folder in Server Path, I'll create one..."
        New-Item -ItemType Directory -Path "$($ServerPath)\$($OfficeFolder)\$($OutlookOfficeUI)\"
    }
    Copy-Item -Path "$($OutlookPath)\*.officeUI" -Destination "$($ServerPath)\$($OfficeFolder)\$($OutlookOfficeUI)\" -Force

    reg.exe EXPORT "HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook\Profiles" "$($ServerPath)\$($OfficeFolder)\OutlookProfiles.reg" /Y
    reg.exe EXPORT "HKEY_CURRENT_USER\Software\Microsoft\Office\" "$($ServerPath)\$($OfficeFolder)\OfficeSettings.reg" /Y

}
else {
    Write-Host "We are not using Office"
}