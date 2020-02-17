$Folder = "GPO"
$File = "$env:USERNAME"
$Counter = 0

# 1 Check if GPO Folder exist on root
if (-Not (Test-Path C:\$Folder)){
    #Write-Host "No Signature Folder in AppData, I'll create one..."
    New-Item -ItemType Directory -Path C:\$Folder  
}

# 2 Check if File exist
do {
    $Counter++
} until ((-Not(Test-Path C:\$Folder\$File-$Counter.html)))

# 3 GPresult
gpresult.exe /H "C:\$Folder\$File-$Counter.html"

# 4 Run current Result in Internet Explorer
$IE = New-Object -ComObject InternetExplorer.Application
$IE.Visible = $true
$IE.Navigate("C:\$Folder\$File-$Counter.html")