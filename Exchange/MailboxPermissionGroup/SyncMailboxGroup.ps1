# Import-MailboxPermissionGroupFA.ps1
# Version 1.0.2
# changelog 
#   v1.0.1 - removed some specific customizations
#   v1.0 - renamed from Set-MailboxPermissionsGroupFA.ps1
# Dave Stork,OGD, 2011-12-13
# Sets FullAccess permissions directly on mailboxes to members and submembers of given group in CSV file

# Import-CSV to import a list of mailboxes and groups.
param($ListLocation)	
$List = Import-Csv "C:\PowerShell_MailboxPermission\Mailbox.csv"	

function Add-MailboxPermissionGroupFA {
	# Add-MailboxPermissionGroupFA.ps1
	# Version 0.9
	# Dave Stork, OGD, 2011-12-12
	# Adds the Full Access permission directly to Mailbox of all members of Group and it's sub-groups
	# This is done by recursivly extract users from Group and adding into an array, which is used in a
	# loop to add permissions. This workaround will allow the Automapping feature to work for groupmembers.

	param([string]$Group,[string]$Mailbox)

	# Helper function to get group members recursively
	# This is from Steve Goodman 
	# http://www.stevieg.org/2010/12/report-exchange-mailboxes-group-members-full-access/
	function Get-GroupMembersRecursive 
	{
    	param($Group)
    	[array]$Members = @()
    	$Group = Get-Group $Group -ErrorAction SilentlyContinue -ResultSize Unlimited
    	if (!$Group)
    	{
        	throw "Group not found"
    	}
    	foreach ($Member in $Group.Members)
    	{
        	if (Get-Group $Member -ErrorAction SilentlyContinue -ResultSize Unlimited)
        	{
            	$Members += Get-GroupMembersRecursive -Group $Member
        	} else {
            	$Members += ((get-user $Member.Name -ResultSize Unlimited).SamAccountName)
        	}
    	}
    	$Members = $Members | Select -Unique
    	return $Members
	}
	# List all current non inherited Full Access permissions, excluding SELF
	$SAMGroup = Get-Group $Group
	$SAMGroup = $SAMGroup.SamAccountName
	$CurrentMailboxPermission = Get-MailboxPermission -Identity $Mailbox | where { ($_.AccessRights -like "*FullAccess*") -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF")}| Select User 

	# Cleanup all permissions directly added to Mailbox (not inherited), this is necessary to keep Group memberships 
	# and actuall added permission the same. Note: the assumption is that Full Access permissions are only
	# handed out via used security group and not manually. All other accounts and groups will have their permissions removed
	foreach ($User in $CurrentMailboxPermission){
		$User = [String] $User.User
		Write-Output "Removing FullAccess permission for $User"
		Remove-MailboxPermission -Identity $Mailbox -User $User -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false
	}

	# Listing every unique member of every group recursivly
	[array]$Members = @();
	$Group = Get-Group $Group -ErrorAction SilentlyContinue -ResultSize Unlimited;
	if (!$Group)
	{
    	throw "Group not found"
	}
	[array]$Members = Get-GroupMembersRecursive -Group $Group

	# Adding the mailbox permission Full Access to users in group and subgroups on mailbox
	Write-Output "The following users have Full Access on $Mailbox :"
	foreach ($Member in $Members) {
			Add-MailboxPermission -Identity $Mailbox -User $Member -AccessRights FullAccess
	}
	
}


foreach ($ListRow in $List){
	Add-MailboxPermissionGroupFA -Group $ListRow.Group -Mailbox $ListRow.Mailbox
}		