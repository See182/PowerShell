# Search in the CIM (Extended Systemsettings)
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -notlike "$env:USERNAME" -and $_.LocalPath -notlike "C:\Windows\*"} | Remove-CimInstance

# Search in the C:\Users Folder
Get-ChildItem -Directory -Exclude Public, $env:USERNAME -Path C:\Users | Remove-Item -Force -Recurse

# Search in the Registry
$UserProfile = Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -like "$env:USERNAME"}
Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Exclude S-1-5-18,S-1-5-19,S-1-5-20,$UserProfile.SID | Remove-Item -Force -Recurse