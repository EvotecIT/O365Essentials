function Set-O365OrgReleasePreferences {
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
