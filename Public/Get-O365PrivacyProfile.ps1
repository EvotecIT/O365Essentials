function Get-O365PrivacyProfile {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/privacypolicy"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}