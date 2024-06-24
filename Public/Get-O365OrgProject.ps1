function Get-O365OrgProject {
    <#
    .SYNOPSIS
    Retrieves information about the organization's Project settings.

    .DESCRIPTION
    This function retrieves information about the organization's Project settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.

    .PARAMETER NoTranslation
    Switch to indicate whether to skip translation of output.

    .EXAMPLE
    Get-O365OrgProject -Headers $headers -NoTranslation

    .NOTES
    This function retrieves information about the organization's Project settings from the specified URI.
    #>
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
