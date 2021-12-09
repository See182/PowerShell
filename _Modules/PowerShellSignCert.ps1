$params = @{
    Subject = 'CN=PowerShell Signing Cert'
    Type = 'CodeSigning'
    CertStoreLocation = 'Cert:\CurrentUser\My'
    HashAlgorithm = 'sha256'
    KeyLength = '4096'
    FriendlyName = 'Concat AG StKir'
}
$cert = New-SelfSignedCertificate @params