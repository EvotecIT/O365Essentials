Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Set-O365Planner -AllowCalendarSharing $true
Set-O365Forms -InOrgFormsPhishingScanEnabled $true
Set-O365AzureSpeechServices -AllowTheOrganizationWideLanguageModel $false
Set-O365BriefingEmail -SubscribeByDefault $false
Set-O365CalendarSharing -SharingOption CalendarSharingFreeBusyReviewed
Set-O365Cortana -Enabled $false
Set-O365Dynamics365SalesInsights -ServiceEnabled $false
Set-O365Groups -AllowGuestAccess $true -AllowGuestsAsMembers $true