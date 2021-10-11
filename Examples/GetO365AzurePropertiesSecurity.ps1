Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365AzureProperties -Verbose | Format-List *

Set-O365AzureProperties -Verbose -Name "Evotec Test" -TechnicalContact 'test@evotec.pl' -GlobalPrivacyContact 'test@evotec.pl' -PrivacyStatementURL "https://test.pl" -WhatIf
Set-O365AzureProperties -Verbose -Name "Evotec" -TechnicalContact 'test@evotec.pl' -GlobalPrivacyContact $null -PrivacyStatementURL $null -WhatIf

Get-O365AzurePropertiesSecurity -Verbose | Format-List *
Set-O365AzurePropertiesSecurity -EnableSecurityDefaults $true -Verbose -WhatIf