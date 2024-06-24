function Set-O365OrgCortana {
    <#
        .SYNOPSIS
        Configures the Cortana settings for an Office 365 organization.
        .DESCRIPTION
        This function allows you to enable or disable the Cortana service for your Office 365 organization.
        It sends a POST request to the Office 365 admin API with the specified settings.
        .PARAMETER Headers
        Specifies the headers for the API request. Typically includes authorization tokens.
        .PARAMETER Enabled
        Specifies whether the Cortana service should be enabled.
        .EXAMPLE
        $headers = @{Authorization = "Bearer your_token"}
        Set-O365OrgCortana -Headers $headers -Enabled $true

        This example enables the Cortana service for the Office 365 organization.
        .NOTES
        This function sends a POST request to the Office 365 admin API with the specified settings.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $Enabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/cortana"

    $Body = @{
        Enabled = $Enabled
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
