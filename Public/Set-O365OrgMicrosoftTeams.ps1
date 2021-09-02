function Set-O365OrgMicrosoftTeams {
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