function Get-O365AzureExternalIdentitiesPolicies {
    <#
        .SYNOPSIS
        Retrieves Azure external identities policies from the specified endpoint.
        .DESCRIPTION
        This function retrieves Azure external identities policies from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .PARAMETER NoTranslation
        A switch parameter to indicate whether to skip translation of the output.
        .EXAMPLE
        Get-O365AzureExternalIdentitiesPolicies -Headers $headers -NoTranslation
    #>
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/IdentityProviders
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/B2B/b2bPolicy'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            $Output
        }
    }
}
