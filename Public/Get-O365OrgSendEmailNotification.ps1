function Get-O365OrgSendEmailNotification {
    [CmdletBinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/sendfromaddress"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}