function Get-O365OrgPlanner {
    <#
    .SYNOPSIS
    Retrieves information about Planner settings from the specified URI.

    .DESCRIPTION
    This function retrieves information about Planner settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.

    .EXAMPLE
    Get-O365OrgPlanner -Headers $headers

    .NOTES
    This function retrieves information about Planner settings from the specified URI.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/services/apps/planner"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            # Thos are always the same
            #id                   = $Output.id # : 1
            #isPlannerAllowed     = $Output.isPlannerAllowed # : True
            allowCalendarSharing = $Output.allowCalendarSharing # : True
            # GUI doesn't show that
            # allowTenantMoveWithDataLoss         = $Output.allowTenantMoveWithDataLoss # : False
            # allowRosterCreation                 = $Output.allowRosterCreation # : True
            # allowPlannerMobilePushNotifications = $Output.allowPlannerMobilePushNotifications # : True
        }
    }
}
