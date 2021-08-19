function Get-O365ModernAuthentication {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/modernAuth"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}