function Set-O365OrgOfficeOnTheWeb {
    <#
    .SYNOPSIS
    Enables or disables Office on the web for an Office 365 tenant.

    .DESCRIPTION
    This function allows you to enable or disable the Office on the web feature for your Office 365 organization. It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER Enabled
    Specifies whether Office on the web should be enabled or disabled. This parameter is mandatory.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgOfficeOnTheWeb -Headers $headers -Enabled $true

    This example enables Office on the web for the Office 365 organization.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgOfficeOnTheWeb -Headers $headers -Enabled $false

    This example disables Office on the web for the Office 365 organization.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $Enabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officeonline"

    $Body = @{
        Enabled = $Enabled
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
