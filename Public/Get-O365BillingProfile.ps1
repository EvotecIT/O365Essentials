function Get-O365BillingProfile {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/moderncommerce/checkaccess/bulk?api-version=3.0&accountId=91e58......."

    $Body = @{
        "permissionId"       = "40000000-aaaa-bbbb-ccc............"
        "organizationId"     = "19419c1b-1bf1-41...."
        "commerceObjectType" = "BillingGroup"
        "commerceObjectId"   = "6YPQ-QFKZ....."
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}