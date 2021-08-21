Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$Authorization = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365Planner -Authorization $Authorization -Verbose
Get-O365Forms -Authorization $Authorization -Verbose
Get-O365AzureSpeechServices -Authorization $Authorization -Verbose
Get-O365Bookings -Authorization $Authorization -Verbose
Get-O365BriefingEmail -Authorization $Authorization -Verbose
Get-O365CalendarSharing -Authorization $Authorization -Verbose
Get-O365Cortana -Authorization $Authorization -Verbose
Get-O365Dynamics365CustomerVoice -Authorization $Authorization -Verbose
Get-O365Dynamics365SalesInsights -Authorization $Authorization -Verbose
Get-O365GraphDataConnect -Authorization $Authorization -Verbose
Get-O365MicrosoftTeams -Authorization $Authorization -Verbose
Get-O365ToDo -Authorization $Authorization -Verbose
Get-O365Groups -Authorization $Authorization -Verbose
Get-O365ModernAuthentication -Authorization $Authorization -Verbose
Get-O365MyAnalytics -Authorization $Authorization -Verbose
Get-O365OfficeOnTheWeb -Authorization $Authorization -Verbose
Get-O365OfficeProductivity -Authorization $Authorization -Verbose
Get-O365Reports -Authorization $Authorization -Verbose
Get-O365SharePoint -Authorization $Authorization -Verbose
Get-O365Sway -Authorization $Authorization -Verbose
Get-O365UserConsentApps -Authorization $Authorization -Verbose
Get-O365Project -Authorization $Authorization -Verbose
Get-O365UserOwnedApps -Authorization $Authorization -Verbose
Get-O365InstallationOptions -Authorization $Authorization -Verbose
Get-O365BingDataCollection -Authorization $Authorization -Verbose
Get-O365DataLocation -Authorization $Authorization -Verbose
Get-O365PasswordExpirationPolicy -Authorization $Authorization -Verbose
Get-O365PrivacyProfile -Authorization $Authorization -Verbose
Get-O365Sharing -Authorization $Authorization -Verbose
Get-O365HelpdeskInformation -Authorization $Authorization -Verbose
Get-O365OrganizationInformation -Authorization $Authorization -Verbose
Get-O365ReleasePreferences -Authorization $Authorization -Verbose
Get-O365CustomThemes -Authorization $Authorization -Verbose
Get-O365DirectorySyncErrors -Authorization $Authorization -Verbose
Get-O365ConsiergeAll -Authorization $Authorization -Verbose
Get-O365BillingAccounts -Authorization $Authorization -Verbose
Get-O365BillingNotificationsList -Authorization $Authorization -Verbose
Get-O365BillingNotifications -Authorization $Authorization -Verbose