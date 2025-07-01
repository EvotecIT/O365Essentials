Import-Module .\O365Essentials.psd1 -Force

# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose

Get-O365BillingLicenseRequests -Verbose
Get-O365BillingLicenseAutoClaim