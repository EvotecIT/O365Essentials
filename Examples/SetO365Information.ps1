Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Set-O365OrgPlanner -AllowCalendarSharing $true
Set-O365OrgForms -InOrgFormsPhishingScanEnabled $true
Set-O365OrgAzureSpeechServices -AllowTheOrganizationWideLanguageModel $false
Set-O365OrgBriefingEmail -SubscribeByDefault $false
Set-O365OrgCalendarSharing -SharingOption CalendarSharingFreeBusyReviewed
Set-O365OrgCortana -Enabled $false
Set-O365OrgDynamics365SalesInsights -ServiceEnabled $false
Set-O365OrgGroups -AllowGuestAccess $true -AllowGuestsAsMembers $true