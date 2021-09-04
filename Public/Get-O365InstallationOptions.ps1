function Get-O365OrgInstallationOptions {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Branches = @{
        "0" = 'Not applicable'
        "1" = "CurrentChannel"
        "3" = 'MonthlyEnterpriseChannel'
        "2" = 'SemiAnnualEnterpriseChannel'
    }

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/usersoftware"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($NoTranslation) {
        $Output.UserSoftwareSettings
    } else {
        if ($Output.UserSoftwareSettings) {
            [PSCustomObject] @{
                WindowsBranch           = $Branches[$($Output.UserSoftwareSettings[0].Branch.ToString())]
                WindowsClient           = $Output.UserSoftwareSettings[0].ClientVersion
                WindowsLastUpdate       = $Output.UserSoftwareSettings[0].BranchLastUpdateTime
                WindowsOffice           = $Output.UserSoftwareSettings[0].ServiceStatusMap.'Office (includes Skype for Business),MicrosoftOffice_ClientDownload'
                WindowsSkypeForBusiness = $Output.UserSoftwareSettings[0].ServiceStatusMap.'Skype for Business (Standalone),MicrosoftCommunicationsOnline';
                MacBranch               = $Branches[$($Output.UserSoftwareSettings[1].Branch.ToString())]
                MacClient               = $Output.UserSoftwareSettings[1].ClientVersion
                MacLastUpdate           = $Output.UserSoftwareSettings[1].BranchLastUpdateTime
                MacOffice               = $Output.UserSoftwareSettings[1].ServiceStatusMap.'Office,MicrosoftOffice_ClientDownload'
                MacSkypeForBusiness     = $Output.UserSoftwareSettings[1].LegacyServiceStatusMap.'Skype for Business (X EI Capitan 10.11 or higher),MicrosoftCommunicationsOnline'
            }
        }
    }
}