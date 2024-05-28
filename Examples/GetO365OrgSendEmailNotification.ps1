Import-Module .\O365Essentials.psd1 -Force

#  Setters and Getters for Office 365 Org Send Email Notification
# - https://admin.microsoft.com/Adminportal/Home?#/Settings/OrganizationProfile/:/Settings/L1/SendFromAddressSettings

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365OrgSendEmailNotification -Verbose

Set-O365OrgSendEmailNotification -SendFromAddress 'noreply1@evotec.pl' -Verbose

Get-O365OrgSendEmailNotification -Verbose

Set-O365OrgSendEmailNotification -Remove -Verbose

Get-O365OrgSendEmailNotification -Verbose