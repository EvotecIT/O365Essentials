Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
$null = Connect-O365Admin -Verbose -Credential $Credentials

# We then used connection from above internally on module scope to get the tenant's information
Get-O365Forms -Verbose
Get-O365Planner -Verbose
Get-O365Forms -Verbose
Get-O365AzureSpeechServices -Verbose
Get-O365Bookings -Verbose
Get-O365BriefingEmail -Verbose
Get-O365CalendarSharing -Verbose
Get-O365Cortana -Verbose
Get-O365Dynamics365CustomerVoice -Verbose
Get-O365Dynamics365SalesInsights -Verbose
Get-O365GraphDataConnect -Verbose
Get-O365MicrosoftTeams -Verbose
Get-O365ToDo -Verbose
Get-O365Groups -Verbose
Get-O365ModernAuthentication -Verbose
Get-O365MyAnalytics -Verbose
Get-O365OfficeOnTheWeb -Verbose
Get-O365OfficeProductivity -Verbose
Get-O365Reports -Verbose
Get-O365SharePoint -Verbose
Get-O365Sway -Verbose
Get-O365UserConsentApps -Verbose
Get-O365Project -Verbose
Get-O365UserOwnedApps -Verbose
Get-O365InstallationOptions -Verbose

# Not ready yet
Get-O365CommunicationToUsers -Verbose # no data
Get-O365News -Verbose # problems
Get-O365MicrosoftSearch -Verbose # problems
Get-O365Scripts -Verbose # problems
Get-O365Whiteboard -Verbose # problems
