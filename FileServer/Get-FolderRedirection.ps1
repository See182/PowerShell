$folders = Get-ChildItem \\caritas.local\daten\Ordnerumleitung | 
	Where { $_.PSIsContainer } | Select -Exp name

$result = @()

$objDomain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://OU=Caritas,DC=caritas,DC=local")
 
$strFilter = "(&(objectCategory=person)(objectClass=user))"
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Subtree"
 
$colProplist = "samaccountname"
 foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}
 
$colResults = $objSearcher.FindAll()
 
foreach ($objResult in $colResults)
{
	$objItem = $objResult.Properties
	$result += $objItem.samaccountname
}

Compare-Object $folders $result | Where {$_.SideIndicator -eq "<="} | Out-File C:\DFSReports\username.txt