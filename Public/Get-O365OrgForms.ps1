function Get-O365OrgForms {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/officeforms/'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}