Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$Authorization = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365OrgPlanner -Authorization $Authorization -Verbose
Get-O365OrgForms -Authorization $Authorization -Verbose
Get-O365OrgAzureSpeechServices -Authorization $Authorization -Verbose
Get-O365OrgBookings -Authorization $Authorization -Verbose
Get-O365OrgBriefingEmail -Authorization $Authorization -Verbose
Get-O365OrgCalendarSharing -Authorization $Authorization -Verbose
Get-O365OrgCortana -Authorization $Authorization -Verbose
Get-O365OrgDynamics365CustomerVoice -Authorization $Authorization -Verbose
Get-O365OrgDynamics365SalesInsights -Authorization $Authorization -Verbose
Get-O365OrgGraphDataConnect -Authorization $Authorization -Verbose
Get-O365OrgMicrosoftTeams -Authorization $Authorization -Verbose
Get-O365OrgToDo -Authorization $Authorization -Verbose
Get-O365OrgGroups -Authorization $Authorization -Verbose
Get-O365OrgModernAuthentication -Authorization $Authorization -Verbose
Get-O365OrgMyAnalytics -Authorization $Authorization -Verbose
Get-O365OrgOfficeOnTheWeb -Authorization $Authorization -Verbose
Get-O365OrgOfficeProductivity -Authorization $Authorization -Verbose
Get-O365OrgReports -Authorization $Authorization -Verbose
Get-O365OrgSharePoint -Authorization $Authorization -Verbose
Get-O365OrgSway -Authorization $Authorization -Verbose
Get-O365OrgUserConsentApps -Authorization $Authorization -Verbose
Get-O365OrgProject -Authorization $Authorization -Verbose
Get-O365OrgUserOwnedApps -Authorization $Authorization -Verbose
Get-O365OrgInstallationOptions -Authorization $Authorization -Verbose
Get-O365OrgBingDataCollection -Authorization $Authorization -Verbose
Get-O365OrgDataLocation -Authorization $Authorization -Verbose
Get-O365OrgPasswordExpirationPolicy -Authorization $Authorization -Verbose
Get-O365OrgPrivacyProfile -Authorization $Authorization -Verbose
Get-O365OrgSharing -Authorization $Authorization -Verbose
Get-O365OrgHelpdeskInformation -Authorization $Authorization -Verbose
Get-O365OrgOrganizationInformation -Authorization $Authorization -Verbose
Get-O365OrgReleasePreferences -Authorization $Authorization -Verbose
Get-O365OrgCustomThemes -Authorization $Authorization -Verbose
Get-O365DirectorySyncErrors -Authorization $Authorization -Verbose
Get-O365ConsiergeAll -Authorization $Authorization -Verbose
Get-O365BillingAccounts -Authorization $Authorization -Verbose
Get-O365BillingNotificationsList -Authorization $Authorization -Verbose
Get-O365BillingNotifications -Authorization $Authorization -Verbose
Get-O365DirectorySync -Verbose
Get-O365OrgDynamics365ConnectionGraph -Verbose