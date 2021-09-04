function Set-O365OrgInstallationOptions {
    <#
    .SYNOPSIS
    Choose how often users get feature updates and the Microsoft apps that users can install on their own devices.

    .DESCRIPTION
    Choose how often users get feature updates and the Microsoft apps that users can install on their own devices.

    .PARAMETER Headers
    Parameter description

    .PARAMETER WindowsBranch
    Enable/Disable Windows

    .PARAMETER WindowsOffice
    Parameter description

    .PARAMETER WindowsSkypeForBusiness
    Parameter description

    .PARAMETER MacOffice
    Parameter description

    .PARAMETER MacSkypeForBusiness
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    It takes a while for GUI to report these changes. Be patient.

    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string][ValidateSet('CurrentChannel', 'MonthlyEnterpriseChannel', 'SemiAnnualEnterpriseChannel')] $WindowsBranch,
        [nullable[bool]] $WindowsOffice,
        [nullable[bool]] $WindowsSkypeForBusiness,
        [nullable[bool]] $MacOffice,
        [nullable[bool]] $MacSkypeForBusiness
    )
    $ReverseBranches = @{
        "CurrentChannel"              = 1
        "MonthlyEnterpriseChannel"    = 3
        "SemiAnnualEnterpriseChannel" = 2
    }

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/usersoftware"

    $CurrentSettings = Get-O365OrgInstallationOptions -NoTranslation -Headers $Headers
    if ($CurrentSettings) {
        $Body = @{
            UserSoftwareSettings = $CurrentSettings
        }

        if ($WindowsBranch) {
            $Body.UserSoftwareSettings[0].Branch = $ReverseBranches[$WindowsBranch]
            # we probably should update "BranchLastUpdateTime": "2021-09-02T21:54:02.953Z",
            # but I am not sure if it matters
        }
        if ($null -ne $WindowsOffice) {
            $Body.UserSoftwareSettings[0].ServiceStatusMap.'Office (includes Skype for Business),MicrosoftOffice_ClientDownload' = $WindowsOffice
        }
        if ($null -ne $WindowsSkypeForBusiness) {
            $Body.UserSoftwareSettings[0].ServiceStatusMap.'Skype for Business (Standalone),MicrosoftCommunicationsOnline' = $WindowsSkypeForBusiness
        }
        if ($null -ne $MacOffice) {
            $Body.UserSoftwareSettings[1].ServiceStatusMap.'Office,MicrosoftOffice_ClientDownload' = $MacOffice
        }
        if ($null -ne $MacSkypeForBusiness) {
            $Body.UserSoftwareSettings[1].LegacyServiceStatusMap.'Skype for Business (X EI Capitan 10.11 or higher),MicrosoftCommunicationsOnline' = $MacSkypeForBusiness
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}