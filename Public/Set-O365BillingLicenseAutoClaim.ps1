function Set-O365BillingLicenseAutoClaim {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $EnableAutoClaim
    )
    $Uri = "https://admin.microsoft.com/fd/m365licensing/v1/policies/autoclaim"

    if ($PSBoundParameters.ContainsKey("EnableAutoClaim")) {
        $Body = [ordered] @{
            policyValue = if ($EnableAutoClaim -eq $true) { "Enabled" } else { "Disabled" }
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    }
}