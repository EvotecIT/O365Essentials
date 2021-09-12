Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365AzureMultiFactorAuthentication -Verbose

# Those cmdlets don't seem to work, not sure why
Set-O365AzureMultiFactorAuthentication -Verbose -AccountLockoutDurationMinutes 5 -AccountLockoutCounterResetMinutes 15 -AccountLockoutDenialsToTriggerLockout 10 -WhatIf
Set-O365AzureMultiFactorAuthentication -Verbose -EnableFraudAlert $false -WhatIf