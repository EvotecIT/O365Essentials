function Set-O365OrgProject {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $RoadmapEnabled,
        [nullable[bool]] $ProjectForTheWebEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/projectonline"

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