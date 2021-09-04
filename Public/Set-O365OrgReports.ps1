function Set-O365OrgReports {
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