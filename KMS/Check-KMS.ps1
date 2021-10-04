$OutFolder = "C:\KMS"
$OutFile = "$OutFolder\Output.txt"

New-Item -Path $OutFolder -ItemType Directory

# Get slmgr /dlv information
$SLMGR = cscript.exe C:\Windows\System32\slmgr.vbs /dlv > $OutFile
$SLMGR


$LIC = Select-String -Path $OutFile -Pattern "Licence Status = Licensed"
if ($null -ne $LIC) {
    Write-Host "$env:COMPUTERNAME is licensed"
}
else {
    Write-Host "$env:COMPUTERNAME is not licensed"
}

$KMS = Select-String -Path $OutFile -Pattern "Key management Service is enabled on this machine"
if ($null -ne $KMS) {
    Write-Host "$env:COMPUTERNAME is a KMS host"
    Select-String -Path $OutFile -Pattern "Listening on Port"
    Select-String -Path $OutFile -Pattern "DNS publishing"
}
else {
    Write-Host "$env:COMPUTERNAME is not a KMS host"
}

Remove-Item $OutFile
Remove-Item $OutFolder