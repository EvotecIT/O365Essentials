function Get-O365CopilotPin {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/company/copilotpolicy/pin"
    $OutputSettings = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET
    $OutputSettings
}