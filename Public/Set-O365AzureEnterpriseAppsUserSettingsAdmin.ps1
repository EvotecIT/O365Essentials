function Set-O365AzureEnterpriseAppsUserSettingsAdmin {
    <#
    .SYNOPSIS
    Configures the Microsoft Entra admin consent request policy.

    .DESCRIPTION
    This function updates the documented Microsoft Graph adminConsentRequestPolicy
    object used by the admin consent workflow.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER IsEnabled
    Indicates whether the admin consent request workflow is enabled. The
    UserConsentToAppsEnabled alias is retained for older scripts, but the setting
    controls admin consent requests, not general user consent.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365AzureEnterpriseAppsUserSettingsAdmin -Headers $headers -IsEnabled $true -RequestExpiresInDays 30

    This example enables the admin consent request workflow and sets request
    expiry to 30 days.

    .LINK
    https://learn.microsoft.com/graph/api/adminconsentrequestpolicy-update
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [alias('UserConsentToAppsEnabled')][nullable[bool]] $IsEnabled,
        [nullable[bool]] $NotificationsEnabled,
        [nullable[bool]] $RemindersEnabled,
        [nullable[int]] $RequestExpiresInDays,
        [string[]] $UserApproverId,
        [string[]] $GroupApproverId,
        [string[]] $RoleApproverId,
        [object[]] $Reviewer
    )
    $Uri = 'https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy'
    $CurrentSettings = Invoke-O365Admin -Uri $Uri -Headers $Headers -RequiredGraphScope 'Policy.Read.All|Policy.ReadWrite.ConsentRequest|Directory.Read.All|Directory.ReadWrite.All'
    if (-not $CurrentSettings) {
        Write-Warning -Message 'Set-O365AzureEnterpriseAppsUserSettingsAdmin - Current admin consent request policy could not be read.'
        return
    }

    $Reviewers = if ($PSBoundParameters.ContainsKey('Reviewer')) {
        @(ConvertTo-O365AdminConsentReviewer -Reviewer $Reviewer)
    } elseif ($PSBoundParameters.ContainsKey('UserApproverId') -or $PSBoundParameters.ContainsKey('GroupApproverId') -or $PSBoundParameters.ContainsKey('RoleApproverId')) {
        @(
            foreach ($ApproverId in @($UserApproverId)) {
                if (-not [string]::IsNullOrWhiteSpace($ApproverId)) {
                    [ordered] @{ query = "/users/$ApproverId"; queryType = 'MicrosoftGraph' }
                }
            }
            foreach ($ApproverId in @($GroupApproverId)) {
                if (-not [string]::IsNullOrWhiteSpace($ApproverId)) {
                    [ordered] @{ query = "/groups/$ApproverId"; queryType = 'MicrosoftGraph' }
                }
            }
            foreach ($ApproverId in @($RoleApproverId)) {
                if (-not [string]::IsNullOrWhiteSpace($ApproverId)) {
                    [ordered] @{ query = "/directoryRoles/$ApproverId"; queryType = 'MicrosoftGraph' }
                }
            }
        )
    } else {
        @(ConvertTo-O365AdminConsentReviewer -Reviewer $CurrentSettings.reviewers)
    }

    $Body = [ordered] @{
        isEnabled             = if ($PSBoundParameters.ContainsKey('IsEnabled')) { [bool] $IsEnabled } else { [bool] $CurrentSettings.isEnabled }
        notifyReviewers       = if ($PSBoundParameters.ContainsKey('NotificationsEnabled')) { [bool] $NotificationsEnabled } else { [bool] $CurrentSettings.notifyReviewers }
        remindersEnabled      = if ($PSBoundParameters.ContainsKey('RemindersEnabled')) { [bool] $RemindersEnabled } else { [bool] $CurrentSettings.remindersEnabled }
        requestDurationInDays = if ($PSBoundParameters.ContainsKey('RequestExpiresInDays')) { [int] $RequestExpiresInDays } else { [int] $CurrentSettings.requestDurationInDays }
        reviewers             = @($Reviewers)
    }

    if ($PSCmdlet.ShouldProcess($Uri, 'Update admin consent request policy')) {
        Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body -RequiredGraphScope 'Policy.ReadWrite.ConsentRequest'
    }
}
