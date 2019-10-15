Get-Disk | Where-Object IsOffline –Eq $True | Set-Disk –IsOffline $False
Get-Disk | Where-Object PartitionStyle -Eq "RAW" | Initialize-Disk -PartitionStyle GPT

Get-Partition -DriveLetter C | Set-Volume -NewFileSystemLabel "System"
Get-Disk -Number 1 | New-Partition -UseMaximumSize -DriveLetter F | Format-Volume -NewFileSystemLabel "Binaries" -FileSystem NTFS -Confirm:$false 
Get-Disk -Number 2 | New-Partition -UseMaximumSize -DriveLetter G | Format-Volume -NewFileSystemLabel "Database" -FileSystem NTFS -AllocationUnitSize 65536 -Confirm:$false 
Get-Disk -Number 3 | New-Partition -UseMaximumSize -DriveLetter I | Format-Volume -NewFileSystemLabel "Log" -FileSystem NTFS -AllocationUnitSize 65536 -Confirm:$false 
Get-Disk -Number 4 | New-Partition -UseMaximumSize -DriveLetter J | Format-Volume -NewFileSystemLabel "Backup" -FileSystem NTFS -AllocationUnitSize 65536 -Confirm:$false

Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools -Confirm #Testen#