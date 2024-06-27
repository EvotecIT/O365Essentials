function Set-O365OrgOfficeProductivity {
    <#
    .SYNOPSIS
    Configures the Office 365 organization's productivity score feature.

    .DESCRIPTION
    This function updates the productivity score feature settings for an Office 365 organization. It allows enabling or disabling the feature, which affects the visibility of productivity scores in the Microsoft 365 admin center.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER Enabled
    Specifies whether the productivity score feature should be enabled or disabled. Accepts a boolean value.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgOfficeProductivity -Headers $headers -Enabled $true

    This example enables the productivity score feature for the Office 365 organization.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [alias('ProductivityScoreOptedIn')][parameter(Mandatory)][bool] $Enabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreCustomerOption"

    $Body = @{
        ProductivityScoreOptedIn = $Enabled
        OperationTime            = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}