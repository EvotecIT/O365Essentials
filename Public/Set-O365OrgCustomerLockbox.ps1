function Set-O365OrgCustomerLockbox {
    <#
    .SYNOPSIS
    Configures the Customer Lockbox settings for an Office 365 organization.

    .DESCRIPTION
    This function allows you to enable or disable the Customer Lockbox feature for your Office 365 organization.
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER RequireApproval
    Specifies whether Customer Lockbox should require approval.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgCustomerLockbox -Headers $headers -RequireApproval $true

    This example enables the Customer Lockbox feature for the Office 365 organization.

    .NOTES
    This function sends a POST request to the Office 365 admin API with the specified settings.
    #>
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
