New-NetIPAddress -IPAddress 10.0.0.3 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.0.1 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.0.2
Rename-Computer -Name DHCP1
Restart-Computer

Add-Computer CORP
Restart-Computer

Install-WindowsFeature DHCP -IncludeManagementTools
netsh dhcp add securitygroups
Restart-Service dhcpserver

Add-DhcpServerInDC -DnsName DHCP1.corp.contoso.com -IPAddress 10.0.0.3
Get-DhcpServerInDC

Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2

Set-DhcpServerv4DnsSetting -ComputerName "DHCP1.corp.contoso.com" -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True

$Credential = Get-Credential
Set-DhcpServerDnsCredential -Credential $Credential -ComputerName "DHCP1.corp.contoso.com"

rem At prompt, supply credential in form DOMAIN\user, password


##Variable ##
$SubnetMask = 255.255.255.0
$StartIP = 1
$EndIP = 254

$DHCPServer = DHCP1.kirby.academy
$Gateway = 10.0.0.1
$DNSDomain = kirby.academy
$DNS = 10.0.0.1,10.0.0.2

## Arrays ##
$ScopeName =@("Corpnet","Corpnet1")
$ScopeNetwork = @("10.0.0","10.0.1")


##### Execution
# Check if the arrays are euqal
if (@(Compare-Object $ScopeName.count $ScopeNetwork.count -SyncWindow 0).Length -eq 0) {
    # Concat Arrays
    [int]$ArrayMax = $ScopeName.Count
    if ([int]$ScopeNetwork.count -gt [int]$ScopeName.count) {
        $ArrayMax = $ScopeNetwork.count
    }

    $ArrayConcat = for ( $i = 0; $i -lt $ArrayMax; $i++){
            [PSCustomObject]@{
                Name = $ScopeName[$i]
                Network = $ScopeNetwork[$i]
            }
    }
    # Execute with Array
    Add-DhcpServerv4Scope -name $ArrayConcat.Name -StartRange $($ArrayConcat.Network).$($StartIP) -EndRange $($ArrayConcat.Network).$($EndIP) -SubnetMask $SubnetMask -State Active
    #Add-DhcpServerv4ExclusionRange -ScopeID 10.0.0.0 -StartRange 10.0.0.1 -EndRange 10.0.0.15
    Set-DhcpServerv4OptionValue -OptionID 3 -Value $Gateway -ScopeID $($ArrayConcat.Network).0 -ComputerName $DHCPServer
    Set-DhcpServerv4OptionValue -DnsDomain $DNSDomain -DnsServer $DNS

} else{
    Write-Verbose "Arrays sind Fehlerhaft." 
    Write-Verbose "Anzahl Name:$($ScopeNetwork.count)" 
    Write-Verbose "Anzahl Network:$($ScopeName.count)"
    }