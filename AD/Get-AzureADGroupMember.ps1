$groups = Get-AzureADGroup

foreach ($group in $groups){

    $members =Get-AzureADGroupMember -ObjectId $group.ObjectId

    foreach($member in $members){

        $props = @{

            Group = $group.DisplayName

            DirSyncEnabled= $group.DirSyncEnabled

            UPN = $member.UserPrincipalName

            }

         $object = new-object psobject -Property $props

         $object | Export-Csv C:\temp\output.csv -Append -NoTypeInformation

    }

 }