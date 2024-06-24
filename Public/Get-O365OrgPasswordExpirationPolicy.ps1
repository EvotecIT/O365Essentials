function Get-O365OrgPasswordExpirationPolicy {
    <#
    .SYNOPSIS
    Retrieves password expiration policy information from the specified URI.

    .DESCRIPTION
    This function retrieves password expiration policy information from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.

    .PARAMETER NoTranslation
    Specifies whether to skip translation.

    .EXAMPLE
    Get-O365OrgPasswordExpirationPolicy -Headers $headers -NoTranslation

    .NOTES
    This function retrieves password expiration policy information from the specified URI.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/passwordpolicy"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($NoTranslation) {
        $Output
    } else {
        [PSCustomObject] @{
            PasswordNeverExpires      = $Output.NeverExpire
            DaysBeforePasswordExpires = $Output.ValidityPeriod
            DaysBeforeUserNotified    = $Output.NotificationDays
            # not shown in the GUI
            # MinimumValidityPeriod   : 14
            # MinimumNotificationDays : 1
            # MaximumValidityPeriod   : 730
            # MaximumNotificationDays : 30
        }
    }
}
