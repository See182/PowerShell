$CSVPath = "D:\Git_See182\PowerShell\AD\Create-ADGroup.csv"

Import-CSV $CSVPath -Delimiter ';' | ForEach-Object {
    if (-NOT (Get-ADGroup$_."Group")) {
        New-ADGroup -Name $_."Group" -SamAccountName RODCAdmins -GroupCategory Security -GroupScope Global -DisplayName "RODC Administrators" -Path "CN=Users,DC=Fabrikam,DC=Com" -Description "Members of this group are RODC Administrators"
    }
    #Get-ADGroup $_."Group" | Add-ADGroupMember $_."Users"
    Write-Host "Adding"
    Write-Host "USERS: "$_.Users
    Write-Host "to"
    Write-Host "GROUP: "$_.Group
   }