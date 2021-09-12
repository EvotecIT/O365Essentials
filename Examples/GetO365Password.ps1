Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365PasswordReset -Verbose
# You can do this all in one go, or separately as shown below
# It will use current settings to fill out blanks
Set-O365PasswordReset -Verbose -OfficePhoneOptionEnabled $false -PasswordResetEnabledGroupIds '376aaf31-509e-4a7e-8ea1-6eabbd22b94a' -WhatIf
Set-O365PasswordReset -Verbose -OfficePhoneOptionEnabled $false -PasswordResetEnabledGroupName 'All Users' -WhatIf
Set-O365PasswordReset -Verbose -OfficePhoneOptionEnabled $false -PasswordResetEnabledGroupName 'All Users' -NumberOfAuthenticationMethodsRequired 2 -WhatIf
Set-O365PasswordReset -Verbose -MobileAppCodeOptionAllowed $true -MobilePhoneOptionEnabled $true -EmailOptionEnabled $true -EmailOptionAllowed $true -MobileAppNotificationEnabled $true -WhatIf
Set-O365PasswordReset -Verbose -RegistrationRequiredOnSignIn $true -RegistrationReconfirmIntevalInDays 190 -WhatIf
Set-O365PasswordReset -Verbose -NotifyUsersOnPasswordReset $true -NotifyOnAdminPasswordReset $true

Set-O365PasswordReset -Verbose -MobileAppCodeEnabled $true -EmailOptionEnabled $true -MobilePhoneOptionEnabled $true
Set-O365PasswordReset -Verbose -MobileAppCodeEnabled $true -EmailOptionEnabled $true -MobilePhoneOptionEnabled $true -NumberOfAuthenticationMethodsRequired 2 -WhatIf
Set-O365PasswordReset -Verbose -MobileAppCodeEnabled $true -EmailOptionEnabled $true -MobilePhoneOptionEnabled $true -NumberOfAuthenticationMethodsRequired 1 -WhatIf
# While those settings are in the same page, they require different cmdlet
Get-O365PasswordResetIntegration -Verbose
Set-O365PasswordResetIntegration -WhatIf -Verbose -PasswordWritebackSupported $true
Set-O365PasswordResetIntegration -AllowUsersTounlockWithoutReset $false -PasswordWritebackSupported $true -Verbose -WhatIf
Set-O365PasswordResetIntegration -AllowUsersTounlockWithoutReset $true -PasswordWritebackSupported $true -Verbose -WhatIf
