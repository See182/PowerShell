$AppDataFolder = "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Signatures\"

$FolderRedirectionFolder = "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\Signatures"
$FolderRedirectionPath = "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)\Documents\Outlook-Dateien\"

function Test-ReparsePoint([string]$path) {
    $file = Get-Item $path -Force -ea SilentlyContinue
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
  }

# 1 Check if Signature Folder is in FolderRedirection else Copy the Files in the AppData to the FolderRedirection
if (Test-Path $FolderRedirectionFolder) {
    # True
    Write-Host "Signatures Folder exists"

} else {
    # False
    # Changes the LogDirectory to a local Folder 
    Write-Host "Signatures Folder does not exist, copying Folder from AppData"
    Copy-Item -Path $AppDataFolder -Destination $FolderRedirectionPath -Recurse
}

# 2 Remove Signature Folder in AppData
if (Test-Path $AppDataFolder){
    # True
    Write-Host "Removing Signatures Folder in AppData"
    Remove-Item -Path $AppDataFolder -Force -Recurse 
}

# 3 Link Folder
if (-Not (Test-ReparsePoint $AppDataFolder)){
    Write-Host "Linking AppData to FolderRedirection"
    New-Item -ItemType SymbolicLink -Path $AppDataFolder -Value $FolderRedirectionFolder
}