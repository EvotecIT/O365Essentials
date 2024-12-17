function Set-O365OrgPasswordExpirationPolicy {
    <#
    .SYNOPSIS
    Configures the password expiration policy for an Office 365 organization.

    .DESCRIPTION
    This function updates the password expiration policy settings for an Office 365 organization. It allows specifying whether passwords never expire, 
    the number of days before passwords expire, and the number of days before users are notified of password expiration.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER PasswordNeverExpires
    Specifies whether passwords should never expire. Accepts a nullable boolean value.

    .PARAMETER DaysBeforePasswordExpires
    Specifies the number of days before passwords expire. Accepts a nullable integer value.

    .PARAMETER DaysBeforeUserNotified
    Specifies the number of days before users are notified of password expiration. Accepts a nullable integer value.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgPasswordExpirationPolicy -Headers $headers -PasswordNeverExpires $true -DaysBeforePasswordExpires 90 -DaysBeforeUserNotified 14

    This example sets the password expiration policy to never expire passwords, with a notification period of 14 days before expiration.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter()][nullable[bool]] $PasswordNeverExpires,
        [Parameter()][nullable[int]] $DaysBeforePasswordExpires,
        [Parameter()][nullable[int]] $DaysBeforeUserNotified
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/passwordpolicy"

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
