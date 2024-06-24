function Get-O365AzureExternalIdentitiesEmail {
    <#
        .SYNOPSIS
        Provides functionality to retrieve email authentication method configurations for external identities in Office 365.
        .DESCRIPTION
        This function retrieves email authentication method configurations for external identities in Office 365 from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .PARAMETER NoTranslation
        A switch parameter to indicate whether to skip translation of the output.
        .EXAMPLE
        Get-O365AzureExternalIdentitiesEmail -Headers $headers -NoTranslation
    #>
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/IdentityProviders
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://graph.microsoft.com/beta/policies/authenticationmethodspolicy/authenticationMethodConfigurations/email'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            $Output
        }
    }
}

<# Requires
scp                 : AccessReview.ReadWrite.All AuditLog.Read.All Directory.AccessAsUser.All Directory.Read.All Directory.ReadWrite.All email EntitlementManagement.Read.All Group.ReadWrite.All IdentityProvider.ReadWrite.All IdentityRiskEvent.ReadWri
                      te.All IdentityUserFlow.Read.All openid Policy.Read.All Policy.ReadWrite.AuthenticationFlows Policy.ReadWrite.AuthenticationMethod Policy.ReadWrite.ConditionalAccess profile Reports.Read.All RoleManagement.ReadWrite.Directory Se
                      curityEvents.ReadWrite.All TrustFrameworkKeySet.Read.All User.Export.All User.ReadWrite.All UserAuthenticationMethod.ReadWrite.All

#>
