$params = @{
    Subject = 'CN=PowerShell Signing Cert'
    Type = 'CodeSigning'
    CertStoreLocation = 'Cert:\CurrentUser\My'
    HashAlgorithm = 'sha256'
    KeyLength = '2048'
    FriendlyName = 'Concat AG StKir'
}
$cert = New-SelfSignedCertificate @params






# Sign the PowerShell script
# PARAMETERS:
# File - Specifies the file path of the PowerShell script to sign, eg. C:\ATA\myscript.ps1.
param([string] $file=$(throw "Please specify a filename."))
$cert = @(Get-ChildItem cert:\CurrentUser\My -codesigning)[0]
Set-AuthenticodeSignature -FilePath $file -Certificate $cert -TimeStampServer "http://timestamp.digicert.com"


# Sign the PowerShell script
# PARAMETERS:
# File - Specifies the file path of the PowerShell script to sign, eg. C:\MyScript.ps1 .\Sign-PowershellScript.ps1 .\MyScript.ps1.
param([string] $file=$(throw "Please specify a filename."))
$cert = @(Get-ChildItem cert:\CurrentUser\My -codesigning)[0]
Set-AuthenticodeSignature -FilePath $file -Certificate $cert -TimeStampServer "http://timestamp.verisign.com/scripts/timstamp.dll" 









signtool.exe sign /v /f ..\Work\BOMAG-Code-Signing.pfx /p "Password" /t http://timestamp.verisign.com/scripts/timstamp.dll %exe%%~x1