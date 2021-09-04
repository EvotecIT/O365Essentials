function Set-O365OrgCustomerLockbox {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $RequireApproval
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/security/dataaccess"
    $Body = @{
        RequireApproval = $RequireApproval
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}