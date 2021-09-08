Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

$Licenses = Get-O365AzureLicenses
$Licenses | Format-Table

$Licenses = Get-O365AzureLicenses -ServicePlansComplete
$Licenses | Format-Table

$Licenses = Get-O365AzureLicenses -ServicePlans
$Licenses | Format-Table

$Licenses = Get-O365AzureLicenses -ServicePlans -IncludeLicenseDetails
$Licenses | Format-Table

$ServicePlans = Get-O365AzureLicenses -ServicePlans -LicenseName 'Enterprise Mobility + Security E5' -Verbose
$ServicePlans | Format-Table

$ServicePlans = Get-O365AzureLicenses -ServicePlans -LicenseSKUID 'EMSPREMIUM' -Verbose
$ServicePlans | Format-Table

$ServicePlans = Get-O365AzureLicenses -ServicePlans -LicenseSKUID 'evotecpoland:EMSPREMIUM' -Verbose
$ServicePlans | Format-Table

$ServicePlans = Get-O365AzureLicenses -ServicePlans -LicenseSKUID 'evotecpoland:EMSPREMIUM' -IncludeLicenseDetails -Verbose
$ServicePlans | Format-Table