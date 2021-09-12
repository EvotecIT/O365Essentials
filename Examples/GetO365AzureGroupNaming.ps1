Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365AzureGroupNamingPolicy -Verbose | Format-Table

Set-O365AzureGroupNamingPolicy -Verbose -Prefix 'O365' -Suffix 'Uops', [Company], 'test' -WhatIf
Set-O365AzureGroupNamingPolicy -Verbose -Prefix 'O365' -Suffix '' -WhatIf
Set-O365AzureGroupNamingPolicy -Verbose -RemoveNamingConvention -WhatIf