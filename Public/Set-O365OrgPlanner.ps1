function Set-O365OrgPlanner {
    <#
    .SYNOPSIS
    Configures the Planner settings for an Office 365 organization.

    .DESCRIPTION
    This function updates the Planner settings for an Office 365 organization. It allows enabling or disabling calendar sharing within Planner.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER AllowCalendarSharing
    Specifies whether calendar sharing should be allowed in Planner. Accepts a boolean value.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgPlanner -Headers $headers -AllowCalendarSharing $true

    This example enables calendar sharing in Planner.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $AllowCalendarSharing
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/planner"

    $Body = @{
        allowCalendarSharing = $AllowCalendarSharing
        id                   = "1"
        isPlannerAllowed     = $true
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
