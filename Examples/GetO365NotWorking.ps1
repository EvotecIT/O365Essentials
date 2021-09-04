Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

# Not working
Get-O365OrgNews -Verbose # problems
Get-O365OrgScripts -Verbose # problems
Get-O365OrgWhiteboard -Verbose # problem
Get-O365OrgCommunicationToUsers -Verbose # no data
Get-O365OrgMicrosoftSearch -Verbose # problems
Get-O365SearchIntelligenceBingConfigurations # problems
Get-O365BillingInvoices # not working
Get-O365BillingProfile # not working