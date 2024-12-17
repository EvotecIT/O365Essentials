function Set-O365OrgProject {
    <#
    .SYNOPSIS
    Configures the project settings for an Office 365 organization.

    .DESCRIPTION
    This function updates the project settings for an Office 365 organization. It allows enabling or disabling Roadmap and Project for the Web features.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER RoadmapEnabled
    Specifies whether the Roadmap feature should be enabled or disabled. Accepts a nullable boolean value.

    .PARAMETER ProjectForTheWebEnabled
    Specifies whether the Project for the Web feature should be enabled or disabled. Accepts a nullable boolean value.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgProject -Headers $headers -RoadmapEnabled $true -ProjectForTheWebEnabled $false

    This example enables the Roadmap feature and disables the Project for the Web feature.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $RoadmapEnabled,
        [nullable[bool]] $ProjectForTheWebEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/projectonline"

    $CurrentSettings = Get-O365OrgProject -Headers $Headers -NoTranslation
    if ($CurrentSettings) {
        $Body = @{
            IsRoadmapEnabled          = $CurrentSettings.IsRoadmapEnabled          #: True
            IsModProjEnabled          = $CurrentSettings.IsModProjEnabled          #: True
            RoadmapAvailabilityError  = $CurrentSettings.RoadmapAvailabilityError  #: 0
            ModProjAvailabilityStatus = $CurrentSettings.ModProjAvailabilityStatus #: 0
        }
        if ($null -ne $RoadmapEnabled) {
            $Body.IsRoadmapEnabled = $RoadmapEnabled
        }
        if ($null -ne $ProjectForTheWebEnabled) {
            $Body.IsModProjEnabled = $ProjectForTheWebEnabled
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}
