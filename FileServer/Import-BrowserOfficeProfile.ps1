<#
    .SYNOPSIS
    Synchronize Microsoft Internet Explorer/Edge, Google Chrome, Mozilla Firefox and Office 365 Settings and Profiles.

    .DESCRIPTION
    Synchronizes all Settings and Profiles from local drive to a network drive. Apps included are Microsoft Internet Explorer/Edge, Google Chrome, Mozilla Firefox and Office 365. Local Computer <-- Server

    .NOTES
    ▄▀▀ ▄▀▄ █▄ █ ▄▀▀ ▄▀▄ ▀█▀   ▄▀▄ ▄▀
    ▀▄▄ ▀▄▀ █ ▀█ ▀▄▄ █▀█  █    █▀█ ▀▄█
    Author: Steve Kirby
    Country: Germany
    Released Date (DD/MM/YYYY): 30/08/2021
    Tested with:    Test User was an Administrator
                    Microsoft Windows 10 Enterprise 20H2 Build
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
# Copy Internet Explorer Favorites to the local Computer
Robocopy.exe "$($ServerPath)\$($InternetExplorerFolder)\$($InternetExplorerFavorites)" "$InternetExplorerFavoritesLocalPath" /MIR /NFL /NDL /NJH /NJS /nc /ns /np

# Copy Internet Explorer History to the local Computer
Robocopy.exe "$($ServerPath)\$($InternetExplorerFolder)\$($InternetExplorerHistory)" "$InternetExplorerHistoryLocalPath" /MIR /NFL /NDL /NJH /NJS /nc /ns /np


<##~~~~~~~~~Microsoft Edge                   ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$EdgeProfile = "C:\Users\$($env:USERNAME)\AppData\Local\Microsoft\Edge\User Data\Default"

<###~~~~~~~~Script                           ~~~~~~~~###>
Write-Host "Is a Edge Folder there?"
if (Test-Path "$($ServerPath)\$($EdgeFolder)") {
    Write-Host "Copy Edge Profile"
    # Copy Edge Bookmarks to the local Computer
    Copy-Item -Destination  "$EdgeProfile\" -Path "$($ServerPath)\$($EdgeFolder)\Bookmarks" -Force
    # Copy Edge History to the local Computer
    Copy-Item -Destination  "$EdgeProfile\" -Path "$($ServerPath)\$($EdgeFolder)\History" -Force
    # Copy Edge FavIcons to the local Computer
    Copy-Item -Destination  "$EdgeProfile\" -Path "$($ServerPath)\$($EdgeFolder)\Favicons" -Force
    # Copy Edge Settings to the local Computer
    Copy-Item -Destination  "$EdgeProfile\" -Path "$($ServerPath)\$($EdgeFolder)\Preferences" -Force
}
else {
    Write-Host "We are not using Edge"
}


<##~~~~~~~~~Google Chrome                    ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$ChromeProfile = "C:\Users\$($env:USERNAME)\AppData\Local\Google\Chrome\User Data\Default"

<###~~~~~~~~Script                           ~~~~~~~~###>
Write-Host "Is a Chrome Folder there?"
if (Test-Path "$($ServerPath)\$($ChromeFolder)") {
    Write-Host "Copy Chrome Profile"
    # Copy Chrome Bookmarks to the local Computer
    Copy-Item -Destination  "$ChromeProfile\" -Path "$($ServerPath)\$($ChromeFolder)\Bookmarks" -Force
    # Copy Chrome History to the local Computer
    Copy-Item -Destination  "$ChromeProfile\" -Path "$($ServerPath)\$($ChromeFolder)\History" -Force
    # Copy Chrome FavIcons to the local Computer
    Copy-Item -Destination  "$ChromeProfile\" -Path "$($ServerPath)\$($ChromeFolder)\Favicons" -Force
    # Copy Chrome Settings to the local Computer
    Copy-Item -Destination  "$ChromeProfile\" -Path "$($ServerPath)\$($ChromeFolder)\Preferences" -Force
}
else {
    Write-Host "We are not using Chrome"
}


<##~~~~~~~~~Mozilla Firefox                  ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$FireFoxProfile = "C:\Users\$($env:USERNAME)\AppData\Roaming\Mozilla\Firefox"

<###~~~~~~~~Script                           ~~~~~~~~###>
Write-Host "Is a Firefox Folder there?"
if (Test-Path "$($ServerPath)\$($FirefoxFolder)") {
    Write-Host "Copy Firefox Profile"
    # Copy FireFox Profile to the local Computer
    Robocopy.exe "$($ServerPath)\$($FirefoxFolder)" "$FireFoxProfile" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
}
else {
    Write-Host "We are not using Firefox"
}


<##~~~~~~~~~Office & Outlook                 ~~~~~~~~~##>
<###~~~~~~~~Variables                        ~~~~~~~~###>
$OutlookProfile = "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft"
$OutlookPath = "C:\Users\$($env:USERNAME)\AppData\Local\Microsoft\Office"

<###~~~~~~~~Script                           ~~~~~~~~###>
Write-Host "Is a Office Folder there?"
if (Test-Path "$($ServerPath)\$($OfficeFolder)") {
    Write-Host "Copy Office Files"
    # Copy Outlook Signatures to the local Computer
    Robocopy.exe "$($ServerPath)\$($OfficeFolder)\$($OutlookSignatures)" "$($OutlookProfile)\Signatures\" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
    # Copy Outlook Dictionary to the local Computer
    Robocopy.exe "$($ServerPath)\$($OfficeFolder)\$($OutlookDictionary)" "$($OutlookProfile)\UProof\" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
    # Copy Outlook Templates to the local Computer
    Robocopy.exe "$($ServerPath)\$($OfficeFolder)\$($OutlookTemplates)"  "$($OutlookProfile)\Templates\" /MIR /NFL /NDL /NJH /NJS /nc /ns /np
    # Copy Outlook CorrectionLists to the local Computer
    Copy-Item -Destination "$($OutlookProfile)\Office\" -Path "$($ServerPath)\$($OfficeFolder)\$($OutlookAutoCorrectionLists)\*.acl" -Force
    # Copy Outlook Rules to the local Computer
    Copy-Item -Destination "$($OutlookPath)\16.0\" -Path "$($ServerPath)\$($OfficeFolder)\$($OutlookRulesXML)\outlook.exe_Rules.xml" -Force
    # Copy Outlook Settings to the local Computer
    Copy-Item -Destination "$($OutlookPath)" -Path "$($ServerPath)\$($OfficeFolder)\$($OutlookOfficeUI)\*.officeUI" -Force
    # Import Office and Outlook Settings to the local Computer
    reg.exe IMPORT "$($ServerPath)\$($OfficeFolder)\OutlookProfiles.reg"
    reg.exe IMPORT "$($ServerPath)\$($OfficeFolder)\OfficeSettings.reg"

}
else {
    Write-Host "We are not using Office"
}