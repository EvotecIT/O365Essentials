function Set-O365OrgOfficeProductivity {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [alias('ProductivityScoreOptedIn')][parameter(Mandatory)][bool] $Enabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreCustomerOption"

    $Body = @{
        ProductivityScoreOptedIn = $Enabled
        OperationTime            = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}