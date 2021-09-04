function Set-O365OrgSway {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $ExternalSharingEnabled,
        [nullable[bool]] $PeoplePickerSearchEnabled,
        [nullable[bool]] $FlickrEnabled,
        [nullable[bool]] $PickitEnabled,
        [nullable[bool]] $WikipediaEnabled,
        [nullable[bool]] $YouTubeEnabled

    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/Sway"

    $CurrentSettings = Get-O365OrgSway -Headers $Headers
    if ($CurrentSettings) {
        $Body = [ordered] @{
            ExternalSharingEnabled    = $CurrentSettings.ExternalSharingEnabled    # : True
            PeoplePickerSearchEnabled = $CurrentSettings.PeoplePickerSearchEnabled # : True
            FlickrEnabled             = $CurrentSettings.FlickrEnabled             # : True
            PickitEnabled             = $CurrentSettings.PickitEnabled             # : True
            WikipediaEnabled          = $CurrentSettings.WikipediaEnabled          # : True
            YouTubeEnabled            = $CurrentSettings.YouTubeEnabled            # : True
        }

        if ($null -ne $ExternalSharingEnabled) {
            $Body.ExternalSharingEnabled = $ExternalSharingEnabled
        }
        if ($null -ne $FlickrEnabled) {
            $Body.FlickrEnabled = $FlickrEnabled
        }
        if ($null -ne $PickitEnabled) {
            $Body.PickitEnabled = $PickitEnabled
        }
        if ($null -ne $WikipediaEnabled) {
            $Body.WikipediaEnabled = $WikipediaEnabled
        }
        if ($null -ne $YouTubeEnabled) {
            $Body.YouTubeEnabled = $YouTubeEnabled
        }
        if ($null -ne $PeoplePickerSearchEnabled) {
            $Body.PeoplePickerSearchEnabled = $PeoplePickerSearchEnabled
        }

        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    }
}