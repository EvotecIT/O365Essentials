Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

#Get-O365PasswordReset -Verbose
#Set-O365PasswordReset -Verbose -OfficePhoneOptionEnabled $false -PasswordResetEnabledGroupIds '376aaf31-509e-4a7e-8ea1-6eabbd22b94a'
#Set-O365PasswordReset -Verbose -MobileAppCodeEnabled $true -EmailOptionEnabled $true -MobilePhoneOptionEnabled $true
#Set-O365PasswordReset -Verbose -MobileAppCodeEnabled $true -EmailOptionEnabled $true -MobilePhoneOptionEnabled $true -NumberOfAuthenticationMethodsRequired 2
#Set-O365PasswordReset -Verbose -MobileAppCodeEnabled $true -EmailOptionEnabled $true -MobilePhoneOptionEnabled $true -NumberOfAuthenticationMethodsRequired 1
#Get-O365PasswordResetIntegration -Verbose
#Set-O365PasswordResetIntegration -WhatIf -Verbose -PasswordWritebackSupported $true
#Set-O365PasswordResetIntegration -AccountUnlockEnabled $false -PasswordWritebackSupported $false -Verbose
Set-O365PasswordResetIntegration -AccountUnlockEnabled $true -PasswordWritebackSupported $true -Verbose
