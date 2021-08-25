function Get-O365OrgPlanner {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/services/apps/planner"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            id                                  = $Output.id # : 1
            isPlannerAllowed                    = $Output.isPlannerAllowed # : True
            allowCalendarSharing                = $Output.allowCalendarSharing # : True
            allowTenantMoveWithDataLoss         = $Output.allowTenantMoveWithDataLoss # : False
            allowRosterCreation                 = $Output.allowRosterCreation # : True
            allowPlannerMobilePushNotifications = $Output.allowPlannerMobilePushNotifications # : True
        }
    }
}