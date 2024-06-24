function Set-O365OrgInstallationOptions {
    <#
    .SYNOPSIS
    Configures the installation options for Microsoft Office 365 applications on user devices.

    .DESCRIPTION
    This function allows you to configure how often users receive feature updates and which Microsoft applications they can install on their devices. 
    You can specify the update channel for Windows, and enable or disable the installation of Office and Skype for Business on both Windows and Mac devices.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER WindowsBranch
    Specifies the update channel for Windows. Valid values are 'CurrentChannel', 'MonthlyEnterpriseChannel', and 'SemiAnnualEnterpriseChannel'.

    .PARAMETER WindowsOffice
    Specifies whether the Office suite should be enabled or disabled for Windows devices.

    .PARAMETER WindowsSkypeForBusiness
    Specifies whether Skype for Business should be enabled or disabled for Windows devices.

    .PARAMETER MacOffice
    Specifies whether the Office suite should be enabled or disabled for Mac devices.

    .PARAMETER MacSkypeForBusiness
    Specifies whether Skype for Business should be enabled or disabled for Mac devices.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgInstallationOptions -Headers $headers -WindowsBranch 'CurrentChannel' -WindowsOffice $true -WindowsSkypeForBusiness $false -MacOffice $true -MacSkypeForBusiness $false

    This example sets the update channel for Windows to 'CurrentChannel', enables Office for both Windows and Mac devices, disables Skype for Business for both Windows and Mac devices.

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
