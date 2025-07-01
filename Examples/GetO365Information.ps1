Import-Module .\O365Essentials.psd1 -Force

# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose

# We then used connection from above internally on module scope to get the tenant's information
Get-O365OrgPlanner -Verbose
Get-O365OrgForms -Verbose
Get-O365OrgAzureSpeechServices -Verbose
Get-O365OrgBookings -Verbose
Get-O365OrgBriefingEmail -Verbose
Get-O365OrgCalendarSharing -Verbose
Get-O365OrgCortana -Verbose
Set-O365OrgCortana -Enabled $false -Verbose
Get-O365OrgDynamics365CustomerVoice -Verbose
Get-O365OrgDynamics365SalesInsights -Verbose
Get-O365OrgGraphDataConnect -Verbose
Get-O365OrgMicrosoftTeams -Verbose
Get-O365OrgToDo -Verbose
Get-O365OrgGroups -Verbose
Get-O365OrgModernAuthentication -Verbose
Get-O365OrgMyAnalytics -Verbose
Get-O365OrgOfficeOnTheWeb -Verbose
Get-O365OrgOfficeProductivity -Verbose
Get-O365OrgReports -Verbose
Get-O365OrgSharePoint -Verbose
Get-O365OrgSway -Verbose
Get-O365OrgUserConsentApps -Verbose
Get-O365OrgProject -Verbose
Get-O365OrgUserOwnedApps -Verbose
Get-O365OrgInstallationOptions -Verbose
Get-O365OrgBingDataCollection -Verbose
Get-O365OrgDataLocation -Verbose
Get-O365OrgPasswordExpirationPolicy -Verbose
Get-O365OrgPrivacyProfile -Verbose
Get-O365OrgSharing -Verbose
Get-O365OrgHelpdeskInformation -Verbose
Get-O365OrgOrganizationInformation -Verbose
Get-O365OrgReleasePreferences -Verbose
Get-O365OrgCustomThemes -Verbose
Get-O365DirectorySyncErrors -Verbose
Get-O365ConsiergeAll
Get-O365BillingAccounts -Verbose
Get-O365BillingNotificationsList -Verbose
Get-O365BillingNotifications -Verbose
Get-O365DirectorySync -Verbose
Get-O365OrgDynamics365ConnectionGraph -Verbose
