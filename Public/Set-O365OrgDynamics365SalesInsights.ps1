﻿function Set-O365OrgDynamics365SalesInsights {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $ServiceEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/dci"

    $Body = @{
        ServiceEnabled = $ServiceEnabled
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}