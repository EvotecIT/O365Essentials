function Get-O365AzureSpeechServices {
    [cmdletbinding()]
    param(
        [parameter()][alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    if (-not $Headers -and $Script:AuthorizationO365Cache) {
        $Headers = $Script:AuthorizationO365Cache
    }

    $Uri = "https://admin.microsoft.com/admin/api/services/apps/azurespeechservices"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers

    [PSCustomobject] @{
        AllowTheOrganizationWideLanguageModel = $Output.IsTenantEnabled
    }
}