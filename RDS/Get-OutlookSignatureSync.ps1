$AppDataFolder = "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Signatures"

$FolderRedirectionFolder = "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\Signatures"
$FolderRedirectionPath = "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\"

# 1 Check if Signature Folder is in FolderRedirection else Copy the Files in the AppData to the FolderRedirection
$SignatureFolderRedirectionExist=Test-Path $FolderRedirectionFolder
if ($SignatureFolderRedirectionExist) {
    # True
    Write-Host "Signatures Folder exists"

} else {
    # FalseChanges the LogDirectory to a local Folder 
    Write-Host "Signatures Folder does not exist, copying Folder from AppData"
    Copy-Item -Path $AppDataFolder -Destination $FolderRedirectionPath -Recurse
}

# 2 Remove Signature Folder in AppData
Remove-Item -Path $AppDataFolder -Force -Recurse

# 3 Link Folder
New-Item -ItemType SymbolicLink -Path $AppDataFolder -Value $FolderRedirectionFolder