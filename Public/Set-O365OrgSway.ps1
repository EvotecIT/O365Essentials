function Set-O365OrgSway {
    <#
    .SYNOPSIS
    Configures settings for Microsoft Sway in Office 365.

    .DESCRIPTION
    This function updates the configuration settings for Microsoft Sway in Office 365. It allows enabling or disabling external sharing, people picker search, Flickr, Pickit, Wikipedia, and YouTube.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER ExternalSharingEnabled
    Specifies whether external sharing is enabled or disabled.

    .PARAMETER PeoplePickerSearchEnabled
    Specifies whether people picker search is enabled or disabled.

    .PARAMETER FlickrEnabled
    Specifies whether Flickr integration is enabled or disabled.

    .PARAMETER PickitEnabled
    Specifies whether Pickit integration is enabled or disabled.

    .PARAMETER WikipediaEnabled
    Specifies whether Wikipedia integration is enabled or disabled.

    .PARAMETER YouTubeEnabled
    Specifies whether YouTube integration is enabled or disabled.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgSway -Headers $headers -ExternalSharingEnabled $true -PeoplePickerSearchEnabled $false -FlickrEnabled $true -PickitEnabled $false -WikipediaEnabled $true -YouTubeEnabled $false

    This example enables external sharing, disables people picker search, enables Flickr, disables Pickit, enables Wikipedia, and disables YouTube for Microsoft Sway.
    #>
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
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/Sway"

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
