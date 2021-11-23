$Driver = "HP Universal Printing PCL 6"
## Arrays
$PrinterIP = @("192.168.111.194","192.168.112.176")
$PrinterName =@("BU-Schwaer","BU-Schlosserei")
#PrinterPort
if (@(Compare-Object $PrinterIP.count $PrinterName.count -SyncWindow 0).Length -eq 0) {
    ForEach ($ip in $PrinterIP) {
        if (-not (Get-Printerport -Name IP_$($ip) -ErrorAction SilentlyContinue)) {
            Add-PrinterPort -Name IP_$($ip) -PrinterHostAddress $ip
        }
    }
    # Concat Arrays
    [int]$ArrayMax = $PrinterIP.Count
    if ([int]$PrinterName.count -gt [int]$PrinterIP.count) {
        $ArrayMax = $PrinterName.count
    }
    $ArrayConcat = for ( $i = 0; $i -lt $ArrayMax; $i++){
            [PSCustomObject]@{
                IP = $PrinterIP[$i]
                Name = $PrinterName[$i]
            }
    }
    #PrinterInstall
    $count = 0
    ForEach ($printer in $ArrayConcat) {
        if (-not (Get-Printer -Name $ArrayConcat.Name[$count] -ErrorAction SilentlyContinue)) {
            Write-Host "Creating Printer"
            Write-Host $ArrayConcat.Name[$count]
            Write-Host $ArrayConcat.IP[$count]
            rundll32 printui.dll,PrintUIEntry /if /n $ArrayConcat.Name[$count] /b $ArrayConcat.Name[$count] /m $Driver /r IP_$($ArrayConcat.IP[$count])
        } 
        $count++
        Write-Host $count
    }
} else {
    Write-Verbose "Arrays sind Fehlerhaft." 
    Write-Verbose "Anzahl Array Name:$($PrinterName.count)" 
    Write-Verbose "Anzahl Array IP:$($PrinterIP.count)"
    }