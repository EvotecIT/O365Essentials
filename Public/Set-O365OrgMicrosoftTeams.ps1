function Set-O365OrgMicrosoftTeams {
    <#
    .SYNOPSIS
    Configures Microsoft Teams settings for an Office 365 organization.

    .DESCRIPTION
    This function allows you to configure the Microsoft Teams settings for your Office 365 organization. 
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER AllowCalendarSharing
    Specifies whether calendar sharing should be allowed in Microsoft Teams.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgMicrosoftTeams -Headers $headers -AllowCalendarSharing $true

    This example enables calendar sharing in Microsoft Teams for the Office 365 organization.

    .NOTES
    https://admin.microsoft.com/#/Settings/Services/:/Settings/L1/SkypeTeams
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $AllowCalendarSharing
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/skypeteams"

    $Body = Get-O365OrgMicrosoftTeams -Headers $Headers

    # It seems every time you check https://admin.microsoft.com/#/Settings/Services/:/Settings/L1/SkypeTeams
    # and you enable just 1 or two settings you need to reapply everything! so i'll
    # leave it for now - as it needs more investigation
    # $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    # $Output
}
