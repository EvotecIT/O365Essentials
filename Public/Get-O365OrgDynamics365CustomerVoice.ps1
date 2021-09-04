function Get-O365OrgDynamics365CustomerVoice {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/officeformspro'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}