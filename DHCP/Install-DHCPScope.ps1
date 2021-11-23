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