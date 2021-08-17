function Set-O365AzureSpeechServices {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $AllowTheOrganizationWideLanguageModel
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/azurespeechservices"

    $Body = @{
        isTenantEnabled = $AllowTheOrganizationWideLanguageModel
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers.Headers -Method POST -Body $Body
    $Output
}