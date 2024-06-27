function Set-O365OrgReleasePreferences {
    <#
    .SYNOPSIS
    Configures the release preferences for an Office 365 organization.

    .DESCRIPTION
    This function updates the release preferences for an Office 365 organization. It allows setting the release track to one of the following options:
    - FirstRelease
    - StagedRollout
    - None

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER ReleaseTrack
    Specifies the release track for the organization. Must be one of the following values:
    - FirstRelease
    - StagedRollout
    - None

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgReleasePreferences -Headers $headers -ReleaseTrack 'FirstRelease'

    This example sets the release track to 'FirstRelease'.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][ValidateSet('FirstRelease', 'StagedRollout', 'None')] $ReleaseTrack
    )

    $Uri = 'https://admin.microsoft.com/admin/api/Settings/company/releasetrack'

    $Body = [ordered] @{
        ReleaseTrack = $ReleaseTrack
        ShowCompass  = $false
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
