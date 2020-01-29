$AppDataFolder = "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Signatures"

$FolderRedirectionFolder = "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\Signatures"
$FolderRedirectionPath = "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\"

# 1 Check if Signature Folder is in FolderRedirection else Copy the Files in the AppData to the FolderRedirection
$SignatureFolderRedirectionExist=Test-Path $FolderRedirectionFolder
if ($SignatureFolderRedirectionExist) {
    # True
    write-host "$($FolderRedirectionFolder) Exists"
} else {
    # FalseChanges the LogDirectory to a local Folder 
    write-host "$($FolderRedirectionFolder) Does not exist creating Folder"
    Copy-Item -Path $AppDataFolder -Destination $FolderRedirectionPath -Recurse
}

# 2 Remove Signature Folder in AppData
Remove-Item -Path $AppDataFolder -Force -Recurse
# 3 Link Folder
New-Item -ItemType SymbolicLink -Path $AppDataFolder -Value $FolderRedirectionFolder