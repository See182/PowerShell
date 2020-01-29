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
  } # function found: https://stackoverflow.com/questions/817794/find-out-whether-a-file-is-a-symbolic-link-in-powershell

# 1 Check if Signature Folder is in AppData Folder
if (-Not (Test-Path $AppDataFolder)){
    #Write-Host "No Signature Folder in AppData, I'll create one..."
    New-Item -ItemType Directory -Path $AppDataFolder  
}

# 2 Check if Signature Folder is in FolderRedirection else Copy the Files in the AppData to the FolderRedirection
if (-Not (Test-Path $FolderRedirectionFolder)) {
    #Write-Host "Signatures Folder does not exist, copying Folder from AppData..."
    Copy-Item -Path $AppDataFolder -Destination $FolderRedirectionPath -Recurse
}

# 3 Link Folder
if (-Not (Test-ReparsePoint $AppDataFolder)){
    #Write-Host "Removing Signatures Folder in AppData"
    Remove-Item -Path $AppDataFolder -Force -Recurse 

    #Write-Host "Linking AppData to FolderRedirection"
    New-Item -ItemType SymbolicLink -Path $AppDataFolder -Value $FolderRedirectionFolder
}