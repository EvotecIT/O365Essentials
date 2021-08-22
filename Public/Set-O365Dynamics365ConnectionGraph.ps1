function Set-O365Dynamics365ConnectionGraph {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $ServiceEnabled,
        [string] $ConnectionGraphUsersExclusionGroup
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/dcg"

    $Body = @{
        ServiceEnabled                     = $ServiceEnabled
        ConnectionGraphUsersExclusionGroup = $ConnectionGraphUsersExclusionGroup
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}