function Get-O365OrgCommunicationToUsers {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/EndUserCommunications'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}