Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365OrgMultiFactorAuthentication -Verbose
Set-O365OrgMultiFactorAuthentication -Verbose -AccountLockoutDurationMinutes 5 -AccountLockoutResetMinutes 15 -AccountLockoutThreshold 10 -WhatIf