function Set-O365BillingLicenseAutoClaim {
    <#
    .SYNOPSIS
    Sets the auto-claim policy for Office 365 licenses.

    .DESCRIPTION
    This function enables or disables the auto-claim policy for Office 365 licenses. The auto-claim policy allows users to automatically claim available licenses without administrative intervention.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER EnableAutoClaim
    Specifies whether to enable or disable the auto-claim policy. This parameter is optional.

    .EXAMPLE
    Set-O365BillingLicenseAutoClaim -Headers $headers -EnableAutoClaim $true

    .NOTES
    For more information on managing Office 365 licenses, visit: https://admin.microsoft.com/#/Billing
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $EnableAutoClaim
    )
    $Uri = "https://admin.microsoft.com/fd/m365licensing/v1/policies/autoclaim"

    if ($PSBoundParameters.ContainsKey("EnableAutoClaim")) {
        $Body = [ordered] @{
            policyValue = if ($EnableAutoClaim -eq $true) { "Enabled" } else { "Disabled" }
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    }
}