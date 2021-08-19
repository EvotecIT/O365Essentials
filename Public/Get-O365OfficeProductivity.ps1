function Get-O365OfficeProductivity {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreCustomerOption"
    $Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreConfig/GetProductivityScoreConfig"
    $Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output2Json = $Output2.Output | ConvertFrom-Json
    $Output1Json = $Output1.Output | ConvertFrom-Json
    $Output = [PSCustomObject] @{
        TenantId                  = $Output2Json.TenantId
        ProductivityScoreSignedup = $Output2Json.ProductivityScoreSignedup
        SignupUserPuid            = $Output2Json.SignupUserPuid
        SignupTime                = $Output2Json.SignupTime
        ReadyTime                 = $Output2Json.ReadyTime
        ProductivityScoreOptedIn  = $Output1Json.ProductivityScoreOptedIn
        OperationUserPuid         = $Output1Json.OperationUserPuid
        OperationTime             = $Output1Json.OperationTime
    }
    $Output
}