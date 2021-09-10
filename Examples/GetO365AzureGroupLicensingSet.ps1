Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

#$LicenseGroup = Get-O365GroupLicenses -GroupName 'Test-Group-TestEVOTECPL' -Verbose
#$LicenseGroup | Format-Table
#$LicenseGroup | Format-List

#New-O365License -LicenseName 'Office 365 E3' -Verbose -EnabledServicesDisplayName 'Microsoft Kaizala Pro', 'Whiteboard (Plan 2)', 'Microsoft Forms (Plan E3)'
#New-O365License -LicenseSKUID 'evotecpoland:EMSPREMIUM' -Verbose -DisabledServicesName 'RMS_S_PREMIUM', 'ATA'

Set-O365GroupLicenses -GroupDisplayName 'Test-Group-TestEVOTECPL' -Licenses @(
    New-O365License -LicenseName 'Office 365 E3' -Verbose
    New-O365License -LicenseName 'Enterprise Mobility + Security E5' -Verbose
) -Verbose -WhatIf

Set-O365GroupLicenses -GroupDisplayName 'Test-Group-TestEVOTECPL' -Licenses @(
    New-O365License -LicenseName 'Office 365 E3' -Verbose -DisabledServicesDisplayName 'Microsoft Kaizala Pro', 'Whiteboard (Plan 2)'
    New-O365License -LicenseName 'Enterprise Mobility + Security E5' -Verbose -EnabledServicesDisplayName 'Azure Information Protection Premium P2', 'Microsoft Defender for Identity'
) -Verbose -WhatIf


Set-O365GroupLicenses -GroupDisplayName 'All Users' -Licenses @(
    New-O365License -LicenseName 'Office 365 E3' -Verbose
    New-O365License -LicenseName 'Enterprise Mobility + Security E5' -Verbose
) -WhatIf -Verbose

Set-O365GroupLicenses -GroupDisplayName 'Test-Group-TestEVOTECPL' -Licenses @(
    New-O365License -LicenseName 'Office 365 E3' -Verbose -EnabledServicesDisplayName 'Microsoft Kaizala Pro', 'Whiteboard (Plan 2)', 'Microsoft Forms (Plan E3)'
    New-O365License -LicenseSKUID 'evotecpoland:EMSPREMIUM' -Verbose -EnabledServicesDisplayName 'Azure Information Protection Premium P2', 'Azure Rights Managemen', 'Azure Active Directory Premium P2'
) -WhatIf -Verbose