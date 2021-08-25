function Set-O365OrgPlanner {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $AllowCalendarSharing
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