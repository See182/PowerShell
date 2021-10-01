$certstore = Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Thumbprint -EQ "09a1b9ab60cf43d6a2de2274a8d955fee479620a" }

ForEach ($cert in $certstore) {
    $cert.FriendlyName = "CEM, Beckum, Germany"
}