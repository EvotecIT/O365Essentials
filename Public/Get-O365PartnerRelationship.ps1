function Get-O365PartnerRelationship {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $TenantID
    )
    if (-not $TenantID) {
        if ($Headers.Tenant) {
            $TenantID = $Headers.Tenant
        } elseif ($Script:AuthorizationO365Cache.Tenant) {
            $TenantID = $Script:AuthorizationO365Cache.Tenant
        }
    }
    if ($TenantID) {
        $Uri = "https://admin.microsoft.com/fd/commerceMgmt/partnermanage/partners?customerTenantId=$TenantID&api-version=2.1"
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers

        if ($Output.partners) {
            [PSCustomObject] @{
                id            = $Output.partners.id  #: c2248f0a
                name          = $Output.partners.name  #:
                aadRoles      = Convert-AzureRole -RoleID $Output.partners.aadRoles
                companyType   = $Output.partners.companyType  #: 4
                canRemoveDap  = $Output.partners.canRemoveDap  #: True
                contractTypes = Convert-ContractType -ContractType $Output.partners.contractTypes  #: {3}
                partnerType   = $Output.partners.partnerType  #: 1
            }

        }
    } else {
        Write-Warning -Message "Get-O365PartnerRelationship - TenantID was not found in headers. Skipping."
    }
}