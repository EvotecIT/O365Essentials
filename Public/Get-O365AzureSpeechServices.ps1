function Get-O365AzureSpeechServices {
    [cmdletbinding()]
    param(
        [parameter()][alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/azurespeechservices"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers

    [PSCustomobject] @{
        AllowTheOrganizationWideLanguageModel = $Output.IsTenantEnabled
    }
}