function Get-O365PasswordExpirationPolicy {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/passwordpolicy"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}