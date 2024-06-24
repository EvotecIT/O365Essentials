function Set-O365OrgDynamics365SalesInsights {
    <#
    .SYNOPSIS
    Configures the Dynamics 365 Sales Insights settings for an Office 365 organization.

    .DESCRIPTION
    This function allows you to enable or disable the Dynamics 365 Sales Insights service for your Office 365 organization. 
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER ServiceEnabled
    Specifies whether the Dynamics 365 Sales Insights service should be enabled.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgDynamics365SalesInsights -Headers $headers -ServiceEnabled $true

    This example enables the Dynamics 365 Sales Insights service for the Office 365 organization.

    .NOTES
    This function sends a POST request to the Office 365 admin API with the specified settings.
    #>
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
