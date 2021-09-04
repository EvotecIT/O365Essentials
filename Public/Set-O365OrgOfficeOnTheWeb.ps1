function Set-O365OrgOfficeOnTheWeb {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $Enabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officeonline"

    $Body = @{
        Enabled = $Enabled
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}