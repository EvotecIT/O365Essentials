function Get-O365OrgProject {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/projectonline"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($NoTranslation) {
        $Output
    } else {
        if ($Output) {
            [PSCustomObject] @{
                RoadmapEnabled          = $Output.IsRoadmapEnabled
                ProjectForTheWebEnabled = $Output.IsModProjEnabled
            }
        }
    }
}