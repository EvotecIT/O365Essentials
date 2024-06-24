function Get-O365OrgUserOwnedApps {
    <#
    .SYNOPSIS
    Retrieves organization user owned apps settings.

    .DESCRIPTION
    This function retrieves organization user owned apps settings from the specified URIs using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/store"
    $Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    $Uri = "https://admin.microsoft.com/admin/api/storesettings/iwpurchaseallowed"
    $Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    $Uri = 'https://admin.microsoft.com/fd/m365licensing/v1/policies/autoclaim'
    $Output4 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    [PSCustomObject] @{
        LetUsersAccessOfficeStore = $Output1
        LetUsersStartTrials       = $Output2
        LetUsersAutoClaimLicenses = if ($Output4.tenantPolicyValue -eq 'Disabled') { $false } elseif ($Output4.tenantPolicyValue -eq 'Enabled') { $true } else { $null }
        <#
        {
        "policyId": "Autoclaim",
        "tenantPolicyValue": "Enabled",
        "tenantId": "ceb371f6-"
        }
        #>

    }
}
