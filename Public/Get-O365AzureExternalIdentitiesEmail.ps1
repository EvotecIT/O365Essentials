function Get-O365AzureExternalIdentitiesEmail {
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