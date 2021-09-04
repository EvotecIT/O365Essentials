Import-Module .\O365Essentials.psd1 -Force

# This makes a connection to Office 365 tenant
$null = Connect-O365Admin -Verbose -Tenant 'evotec.pl' #'26ad84bb-8bf5-4819-ad05-32e40dc8d335'

# We then used connection from above internally on module scope to get the tenant's information
Get-O365OrgPlanner -Verbose
Get-O365OrgForms -Verbose
Get-O365OrgAzureSpeechServices -Verbose
Get-O365OrgBookings -Verbose
Get-O365OrgBriefingEmail -Verbose
Get-O365OrgCalendarSharing -Verbose
Get-O365OrgCortana -Verbose
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
Get-O365OrgPartnerRelationship -Verbose
Get-O365OrgMultiFactorAuthentication -Verbose

Get-O365Domains -Verbose | Format-Table *
Get-O365Domains | Out-HtmlView -Online -Filtering