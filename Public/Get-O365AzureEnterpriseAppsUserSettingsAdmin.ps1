function Get-O365AzureEnterpriseAppsUserSettingsAdmin {
    <#
    .SYNOPSIS
    Retrieves user settings for Azure Enterprise Apps with admin consent flow.

    .DESCRIPTION
    This function retrieves user settings for Azure Enterprise Apps with admin consent flow based on the provided headers.
    It returns information about request expiration days, notifications, reminders, approvers, and approversV2.

    .PARAMETER Headers
    A dictionary containing the headers for the API request, typically including authorization information.

    .PARAMETER NoTranslation
    Specifies whether to return the user settings without translation.

    .EXAMPLE
    Get-O365AzureEnterpriseAppsUserSettingsAdmin -Headers $headers

    .NOTES
    For more information, visit: https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -RequiredGraphScope 'Policy.Read.All'
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            $ApproversV2 = [ordered] @{
                user  = @()
                group = @()
                role  = @()
            }
            foreach ($Reviewer in @($Output.reviewers)) {
                $Query = $Reviewer.query -replace '^/v1\.0/', '/'
                if ($Query -match '^/users/(?<id>[^/]+)$') {
                    $ApproversV2.user += $Matches.id
                } elseif ($Query -match '^/groups/(?<id>[^/]+)$') {
                    $ApproversV2.group += $Matches.id
                } elseif ($Query -match '^/directoryRoles/(?<id>[^/]+)$') {
                    $ApproversV2.role += $Matches.id
                }
            }
            [PSCustomObject] @{
                isEnabled            = $Output.isEnabled
                requestExpiresInDays = $Output.requestDurationInDays
                notificationsEnabled = $Output.notifyReviewers
                remindersEnabled     = $Output.remindersEnabled
                approvers            = @($ApproversV2.user + $ApproversV2.group + $ApproversV2.role)
                approversV2          = [PSCustomObject] $ApproversV2
                reviewers            = $Output.reviewers
            }
        }
    }
}
