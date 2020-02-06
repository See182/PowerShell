$Folder = "C:\CleanerScript"

# Prepartion
if (-Not (Test-Path $Folder)) {
    New-Item -Path $Folder -ItemType Directory
}

# Search in the CIM (Extended Systemsettings)
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -notlike "$env:USERNAME" -and $_.LocalPath -notlike "C:\Windows\*"} | Remove-CimInstance

# Search in the C:\Users Folder
Get-ChildItem -Directory -Exclude Public, $env:USERNAME -Path C:\Users | Format-Table Name -HideTableHeaders | Out-File -FilePath $Folder\Raw.txt
Get-Content $Folder\Raw.txt | Where-Object { $_ } | Set-Content $Folder\Clean.txt
Remove-Item $Folder\Raw.txt

Start-Process "cmd.exe" "/c C:Clean.cmd"

# Search in the Registry
$UserProfile = Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -like "$env:USERNAME"}
Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Exclude S-1-5-18,S-1-5-19,S-1-5-20,$UserProfile.SID | Remove-Item -Force -Recurse

# Clean the evidence
Remove-Item C:\CleanerScript -Force -Recurse