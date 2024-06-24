function Get-O365OrgAzureSpeechServices {
    <#
        .SYNOPSIS
        Retrieves the status of Azure Speech Services for the organization.
        .DESCRIPTION
        This function queries the Microsoft Graph API to retrieve the status of Azure Speech Services for the organization.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365OrgAzureSpeechServices -Headers $headers
    #>
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
