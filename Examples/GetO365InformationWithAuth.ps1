Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
$Authorization = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365Forms -Authorization $Authorization -Verbose
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

# Not ready yet
Get-O365CommunicationToUsers -Authorization $Authorization -Verbose # no data
Get-O365News -Authorization $Authorization -Verbose # problems
Get-O365MicrosoftSearch -Authorization $Authorization -Verbose # problems
Get-O365Scripts -Authorization $Authorization -Verbose # problems
Get-O365Whiteboard -Authorization $Authorization -Verbose # problems
