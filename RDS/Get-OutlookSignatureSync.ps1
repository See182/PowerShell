$FolderRedirectionPath = "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\Signatures"

# 1 Check if Signature Folder is in FolderRedirection
$SignatureFolderRedirectionExist=Test-Path $FolderRedirectionPath
if ($SignatureFolderRedirectionExist) {
    # True
    write-host "$($FolderRedirectionPath) Exists"
} else {
    # FalseChanges the LogDirectory to a local Folder 
    write-host "$($FolderRedirectionPath) Does not exist fallback to a local dir"
    Copy-Item -Path "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Signatures" -Destination "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\" -Recurse
}

## 2 Remove Signature Folder in AppData
Remove-Item -Path "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Signatures" -Force -Recurse
## 3 Link Folder
New-Item -ItemType SymbolicLink -Path "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Signatures" -Value "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\Signatures"