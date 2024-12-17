function Get-O365AzureExternalCollaborationFlows {
    <#
    .SYNOPSIS
    Provides information about Azure external collaboration flows.

    .DESCRIPTION
    This function retrieves details about Azure external collaboration flows based on the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365AzureExternalCollaborationFlows -Headers $headers

    .NOTES
    WARNING: Invoke-O365Admin - Error JSON: Response status code does not indicate success:
    403 (Forbidden). The application does not have any of the required delegated permissions
    (Policy.Read.All, Policy.ReadWrite.AuthenticationFlows) to access the resource.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://graph.microsoft.com/v1.0/policies/authenticationFlowsPolicy'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
