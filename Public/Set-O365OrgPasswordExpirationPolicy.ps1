function Set-O365OrgPasswordExpirationPolicy {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter()][nullable[bool]] $PasswordNeverExpires,
        [Parameter()][nullable[int]] $DaysBeforePasswordExpires,
        [Parameter()][nullable[int]] $DaysBeforeUserNotified
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/passwordpolicy"

    $CurrentSettings = Get-O365OrgPasswordExpirationPolicy -Headers $Headers -NoTranslation
    if ($CurrentSettings) {
        $Body = @{
            ValidityPeriod   = $CurrentSettings.ValidityPeriod   #: 90
            NotificationDays = $CurrentSettings.NotificationDays #: 14
            NeverExpire      = $CurrentSettings.NeverExpire      #: True
        }
        if ($null -ne $DaysBeforeUserNotified) {
            $Body.NotificationDays = $DaysBeforeUserNotified
        }
        if ($null -ne $DaysBeforePasswordExpires) {
            $Body.ValidityPeriod = $DaysBeforePasswordExpires
        }
        if ($null -ne $PasswordNeverExpires) {
            $Body.NeverExpire = $PasswordNeverExpires
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    }
}