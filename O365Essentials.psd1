@{
    AliasesToExport      = @()
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop', 'Core')
    Copyright            = 'Przemyslaw Klys. All rights reserved.'
    Description          = 'A module that helps to manage some tasks on Office 365/Azure via undocumented API'
    FunctionsToExport    = @('Connect-O365Admin', 'Get-O365AzureSpeechServices', 'Get-O365Bookings', 'Get-O365BriefingEmail', 'Get-O365CalendarSharing', 'Get-O365CommunicationToUsers', 'Get-O365CompanyInformation', 'Get-O365Cortana', 'Get-O365Dynamics365CustomerVoice', 'Get-O365Dynamics365SalesInsights', 'Get-O365Forms', 'Get-O365GraphDataConnect', 'Get-O365Groups', 'Get-O365InstallationOptions', 'Get-O365MicrosoftSearch', 'Get-O365MicrosoftTeams', 'Get-O365ModernAuthentication', 'Get-O365MyAnalytics', 'Get-O365News', 'Get-O365OfficeOnTheWeb', 'Get-O365OfficeProductivity', 'Get-O365Planner', 'Get-O365Project', 'Get-O365Reports', 'Get-O365Scripts', 'Get-O365SharePoint', 'Get-O365Sway', 'Get-O365TenantID', 'Get-O365ToDo', 'Get-O365UserConsentApps', 'Get-O365UserOwnedApps', 'Get-O365Whiteboard', 'Invoke-O365Admin', 'Set-O365AzureSpeechServices', 'Set-O365Forms', 'Set-O365Planner')
    GUID                 = 'a8752d7b-17c8-41db-b3f9-b8f225de028d'
    ModuleVersion        = '0.0.2'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags                       = @('Windows', 'MacOS', 'Linux', 'Office365', 'Graph', 'Azure', 'Unsupported', 'API')
            ProjectUri                 = 'https://github.com/EvotecIT/O365Essentials'
            ExternalModuleDependencies = @('Microsoft.PowerShell.Utility')
        }
    }
    RequiredModules      = @(@{
            ModuleVersion = '0.0.210'
            ModuleName    = 'PSSharedGoods'
            Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
        }, @{
            ModuleVersion = '2.5.2'
            ModuleName    = 'Az.Accounts'
            Guid          = '17a2feff-488b-47f9-8729-e2cec094624c'
        }, 'Microsoft.PowerShell.Utility')
    RootModule           = 'O365Essentials.psm1'
}