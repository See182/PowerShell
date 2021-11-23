## Arrays ##
$Array1 = @("192.168.111.194","192.168.112.176")
$Array2 =@("BU-Schwaer","BU-Schlosserei")
# Check if the arrays are euqal
if (@(Compare-Object $Array1.count $Array2.count -SyncWindow 0).Length -eq 0) {
    # Concat Arrays
    [int]$ArrayMax = $Array1.Count
    if ([int]$Array2.count -gt [int]$Array1.count) {
        $ArrayMax = $Array2.count
    }

    $ArrayConcat = for ( $i = 0; $i -lt $ArrayMax; $i++){
            [PSCustomObject]@{
                Array1 = $Array1[$i]
                Array2 = $Array2[$i]
            }
    }
    # Execute with Array
    Write-Host $ArrayConcat.Array1[$count]
    Write-Host $ArrayConcat.Array2[$count]
} else {
    Write-Verbose "Arrays sind Fehlerhaft." 
    Write-Verbose "Anzahl Array1:$($Array2.count)" 
    Write-Verbose "Anzahl Array2:$($Array1.count)"
    }