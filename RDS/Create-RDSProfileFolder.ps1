$UserFolder = "PATH\$($env:USERNAME)\FOLDER"

if (-Not (Test-Path $UserFolder)) {
    #Write-Host "No user folder on share, I'll create one..."
    New-Item -ItemType Directory -Path $UserFolder
}