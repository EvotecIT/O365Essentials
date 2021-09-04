function Get-O365OrgPasswordExpirationPolicy {
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