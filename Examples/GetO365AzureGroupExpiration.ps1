Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365AzureGroupExpiration -Verbose

# Useful to find out what groups can be used
#$Groups = Get-O365Group -Verbose -UnifiedGroupsOnly
#$Groups | Format-Table

Set-O365AzureGroupExpiration -Verbose -GroupLifeTime 400 -ExpirationGroups 'Wsparcie SPES', 'Kontakt' -ExpirationEnabled Selected -WhatIf
Set-O365AzureGroupExpiration -Verbose -GroupLifeTime 400 -ExpirationGroupsID '283ce825-8c97-4de3-80b1-d51051157b3a', '376aaf31-509e-4a7e-8ea1-6eabbd22b94a' -ExpirationEnabled Selected -WhatIf
Set-O365AzureGroupExpiration -Verbose -GroupLifeTime 400 -ExpirationEnabled None -WhatIf