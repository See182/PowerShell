$SAM = "$($Env:COMPUTERNAME)$"

switch -wildcard ($Env:COMPUTERNAME) {
    "eprimo-RDSHE[0-9][0-9]" {
        Write-Verbose "Found a Remote Desktop Session Host for External Collection"
        Get-ADComputer $Env:COMPUTERNAME | Move-ADObject -TargetPath "OU=RDS_Internal,OU=TerminalServer2019,OU=ServerSystems,DC=eprimo,DC=local" -Verbose
        Add-ADGroupMember “GG_RDSH_RDS_External_Server” -Members $SAM
        Uninstall-WindowsFeature -Name RSAT-AD-PowerShell
    }
    "eprimo-RDSHE[0-9][0-9]" {
        Write-Verbose "Found a Remote Desktop Session Host for Internal Collection"
        Get-ADComputer $Env:COMPUTERNAME | Move-ADObject -TargetPath "OU=RDS_External,OU=TerminalServer2019,OU=ServerSystems,DC=eprimo,DC=local" -Verbose
        Add-ADGroupMember “GG_RDSH_RDS_Internal_Server” -Members $SAM
        Uninstall-WindowsFeature -Name RSAT-AD-PowerShell

    }
    Default{
        Write-Verbose "No Remote Desktop Session Host found"
        EXIT
    }
}




Write-Verbose "Removing Choco Cleaner..."
choco uninstall choco-cleaner -y

Write-Verbose "Removing Chocolatey..."
$VerbosePreference = 'Continue'
if (-not $env:ChocolateyInstall) {
    $message = @(
        "The ChocolateyInstall environment variable was not found."
        "Chocolatey is not detected as installed. Nothing to do."
    ) -join "`n"

    Write-Warning $message
    return
}

if (-not (Test-Path $env:ChocolateyInstall)) {
    $message = @(
        "No Chocolatey installation detected at '$env:ChocolateyInstall'."
        "Nothing to do."
    ) -join "`n"

    Write-Warning $message
    return
}

<#
    Using the .NET registry calls is necessary here in order to preserve environment variables embedded in PATH values;
    Powershell's registry provider doesn't provide a method of preserving variable references, and we don't want to
    accidentally overwrite them with absolute path values. Where the registry allows us to see "%SystemRoot%" in a PATH
    entry, PowerShell's registry provider only sees "C:\Windows", for example.
#>

$machineKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\ControlSet001\Control\Session Manager\Environment\')
$machinePath = $machineKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

$backupPATHs = @(
    "Machine PATH: $machinePath"
)
$backupFile = "C:\_Install\ChocolateyUninstall.txt"
$backupPATHs | Set-Content -Path $backupFile -Encoding UTF8 -Force

$warningMessage = @"
    This could cause issues after reboot where nothing is found if something goes wrong.
    In that case, look at the backup file for the original PATH values in '$backupFile'.
"@

if ($machinePath -like "*$env:ChocolateyInstall*") {
    Write-Verbose "Chocolatey Install location found in Machine Path. Removing..."
    Write-Warning $warningMessage

    $newMachinePATH = @(
        $machinePath -split [System.IO.Path]::PathSeparator |
            Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
    ) -join [System.IO.Path]::PathSeparator

    # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
    # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
    $machineKey.SetValue('PATH', $newMachinePATH, 'ExpandString')
}

# Adapt for any services running in subfolders of ChocolateyInstall
$agentService = Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue
if ($agentService -and $agentService.Status -eq 'Running') {
    $agentService.Stop()
}
# TODO: add other services here

Remove-Item -Path $env:ChocolateyInstall -Recurse -Force

'ChocolateyInstall', 'ChocolateyLastPathUpdate' | ForEach-Object {
    foreach ($scope in 'User', 'Machine') {
        [Environment]::SetEnvironmentVariable($_, [string]::Empty, $scope)
    }
}

$machineKey.Close()

if ($env:ChocolateyToolsLocation -and (Test-Path $env:ChocolateyToolsLocation)) {
    Remove-Item -Path $env:ChocolateyToolsLocation -Recurse -Force
}

foreach ($scope in 'User', 'Machine') {
    [Environment]::SetEnvironmentVariable('ChocolateyToolsLocation', [string]::Empty, $scope)
}