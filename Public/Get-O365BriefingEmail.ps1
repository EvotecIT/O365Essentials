function Get-O365BriefingEmail {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/services/apps/briefingemail"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}