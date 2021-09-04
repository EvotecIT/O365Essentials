function Set-O365OrgUserOwnedApps {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $LetUsersAccessOfficeStore,
        [nullable[bool]] $LetUsersStartTrials,
        [nullable[bool]] $LetUsersAutoClaimLicenses
    )

    if ($null -ne $LetUsersAccessOfficeStore) {
        $Uri = "https://admin.microsoft.com/admin/api/settings/apps/store"
        $Body = @{
            Enabled = $LetUsersAccessOfficeStore
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    }
    if ($null -ne $LetUsersStartTrials) {
        $TrialState = $LetUsersStartTrials.ToString().ToLower()
        $Uri = "https://admin.microsoft.com/admin/api/storesettings/iwpurchase/$TrialState"
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT #-Body $Body
    }
    if ($null -ne $LetUsersAutoClaimLicenses) {

        $Uri = "https://admin.microsoft.com/fd/m365licensing/v1/policies/autoclaim"

        $Body = @{
            policyValue = if ($LetUsersAutoClaimLicenses -eq $true) { 'Enabled' } else { 'Disabled' }
        }

        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    }
}