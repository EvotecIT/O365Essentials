function Get-O365PasswordReset {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/PasswordResetPolicies"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}