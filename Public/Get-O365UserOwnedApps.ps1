function Get-O365UserOwnedApps {
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
        LetUsersAutoClaimLicenses = $Output4.tenantPolicyValue
        <#
        {
        "policyId": "Autoclaim",
        "tenantPolicyValue": "Enabled",
        "tenantId": "ceb371f6-"
        }
        #>

    }
}