$computer = "LocalHost"
$namespace = "root\CIMV2"
$userSessions = Get-WmiObject -class Win32_ServerConnection -computername $computer -namespace $namespace

if($userSessions -ne $null)
{
    Write-Host "The following users are connected to your PC: "

    foreach ($userSession in $userSessions)
    {
        $ComputerName = [system.net.dns]::resolve($usersession.computername).hostname
        $userDetails = [string]::Format("User {0} from machine {1} on share: {2}", $userSession.UserName, $ComputerName, $userSession.ShareName)
        Write-Host $userDetails
    }    

    Read-Host
}