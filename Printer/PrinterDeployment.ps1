
$Driver = "HP Universal Printing PCL 6"
## Arrays
$PrinterIP = @("192.168.111.59","192.168.111.58")
$PrinterName =@("BU-RHP-Einteiler","BU-TEST")
#PrinterPort
if (@(Compare-Object $PrinterIP.count $PrinterName.count -SyncWindow 0).Length -eq 0) {
    ForEach ($ip in $PrinterIP) {
        if (-not (Get-Printerport -Name $ip -ErrorAction SilentlyContinue)) {
            Add-PrinterPort -Name IP_$ip -PrinterHostAddress $ip
        }
    }
    # Concat Arrays
    [int]$ArrayMax = $PrinterIP.Count
    if ([int]$PrinterName.count -gt [int]$PrinterIP.count) { 
        $ArrayMax = $PrinterName.count
    }
    $ArrayConcat = for ( $i = 0; $i -lt $ArrayMax; $i++){
            Write-Verbose "$($PrinterIP[$i]),$($PrinterName[$i])"
            [PSCustomObject]@{
                IP = $PrinterIP[$i]
                Name = $PrinterName[$i]
            }
    }
    #PrinterInstall
    $count = 0
    ForEach ($printer in $ArrayConcat) {
        if (-not (Get-Printer -Name $ArrayConcat.Name[$count] -ErrorAction SilentlyContinue)) {
            Add-Printer -Name $ArrayConcat.Name[$count] -DriverName $Driver -PortName IP_$($ArrayConcat.IP[$count])
        } $count++
    }
} else {
    Write-Host "Arrays sind Fehlerhaft." 
    Write-Host "Anzahl Array Name:$($PrinterName.count)" 
    Write-Host "Anzahl Array IP:$($PrinterIP.count)"
}