function Get-O365ExternalCollaborationFlows {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .EXAMPLE
    An example

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