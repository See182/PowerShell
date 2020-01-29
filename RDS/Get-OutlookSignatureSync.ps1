$Share = "\\caritas.local\data\Profil\FolderRedirection\$($env:USERNAME)"
$Path = "Documents\Outlook-Dateien"
$Folder = "Signatures"


## Leave everything as it is

$AppDataFolder = "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Signatures\"
$FolderRedirectionPath = "$Share\$Path"
$FolderRedirectionFolder = "$FolderRedirectionPath\$Folder"

function Test-ReparsePoint([string]$path) {
    $file = Get-Item $path -Force -ea SilentlyContinue
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
  }

# Tests:
## 1 No Signatures Folders -> error
## 2 Only Signature Folder in AppData -> Runs
## 3 Only Signature Folder in FolderRedirection -> Runs but errors in Line 34
## 4 Two Signature Folders -> Runs and overrides with FolderRedirection
## 5 AppData Signature is already linked -> Runs


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

# 3 Link Folder
if (-Not (Test-ReparsePoint $AppDataFolder)){
    Write-Host "Removing Signatures Folder in AppData"
    Remove-Item -Path $AppDataFolder -Force -Recurse 

    Write-Host "Linking AppData to FolderRedirection"
    New-Item -ItemType SymbolicLink -Path $AppDataFolder -Value $FolderRedirectionFolder
} else {
    Write-Host "Sigantures Folder already linked"
}