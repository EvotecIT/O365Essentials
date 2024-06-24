function Set-O365OrgReports {
    <#
        .SYNOPSIS
        Configures the reporting settings for an Office 365 organization.
        .DESCRIPTION
        This function updates the reporting settings for an Office 365 organization. It allows enabling or disabling privacy settings and Power BI integration for reports.
        .PARAMETER Headers
        Specifies the headers for the API request. Typically includes authorization tokens.
        .PARAMETER PrivacyEnabled
        Specifies whether privacy settings are enabled for reports. Accepts a boolean value.
        .PARAMETER PowerBiEnabled
        Specifies whether Power BI integration is enabled for reports. Accepts a boolean value.
        .EXAMPLE
        $headers = @{Authorization = "Bearer your_token"}
        Set-O365OrgReports -Headers $headers -PrivacyEnabled $true -PowerBiEnabled $false

        This example sets the reporting settings to enable privacy settings and disable Power BI integration.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter()][nullable[bool]] $PrivacyEnabled,
        [Parameter()][nullable[bool]] $PowerBiEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/config/SetTenantConfiguration"

    $Body = @{
        PrivacyEnabled = $PrivacyEnabled
        PowerBiEnabled = $PowerBiEnabled
    }
    Remove-EmptyValue -Hashtable $Body
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
