function Set-O365OrgUserOwnedApps {
    <#
    .SYNOPSIS
    Configures settings for user-owned apps in Office 365.

    .DESCRIPTION
    This function updates the configuration settings for user-owned apps in Office 365. It allows enabling or disabling user access to the Office Store, starting trials, and auto-claiming licenses.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER LetUsersAccessOfficeStore
    Specifies whether users are allowed to access the Office Store.

    .PARAMETER LetUsersStartTrials
    Specifies whether users are allowed to start trials.

    .PARAMETER LetUsersAutoClaimLicenses
    Specifies whether users are allowed to auto-claim licenses.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgUserOwnedApps -Headers $headers -LetUsersAccessOfficeStore $true -LetUsersStartTrials $false -LetUsersAutoClaimLicenses $true

    This example enables user access to the Office Store, disables starting trials, and enables auto-claiming licenses.
    #>
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
