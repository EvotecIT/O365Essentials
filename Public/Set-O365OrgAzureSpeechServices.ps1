function Set-O365OrgAzureSpeechServices {
    <#
    .SYNOPSIS
    Provides functionality to enable or disable the organization-wide language model for Azure Speech Services.

    .DESCRIPTION
    This function allows enabling or disabling the organization-wide language model for Azure Speech Services.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER AllowTheOrganizationWideLanguageModel
    Specifies whether to enable or disable the organization-wide language model.

    .EXAMPLE
    Set-O365OrgAzureSpeechServices -Headers $headers -AllowTheOrganizationWideLanguageModel $true

    .NOTES
    For more information, visit: https://admin.microsoft.com/admin/api/services/apps/azurespeechservices
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $AllowTheOrganizationWideLanguageModel
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/azurespeechservices"

    $Body = @{
        isTenantEnabled = $AllowTheOrganizationWideLanguageModel
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
