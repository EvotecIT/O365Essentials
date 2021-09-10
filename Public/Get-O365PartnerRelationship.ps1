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
            foreach ($Partner in $Output.partners) {
                [PSCustomObject] @{
                    id            = $Partner.id  #: c2248f0a
                    name          = $Partner.name  #:
                    aadRoles      = Convert-AzureRole -RoleID $Partner.aadRoles
                    # i am not 100% sure on the conversion types on different numbers so i'll disable them for now
                    companyType   = $Partner.companyType #Convert-CompanyType -CompanyType $Partner.companyType  #: 4
                    canRemoveDap  = $Partner.canRemoveDap  #: True
                    contractTypes = $Partner.contractTypes # Convert-ContractType -ContractType $Partner.contractTypes  #: {3}
                    partnerType   = $Partner.partnerType  #: 1
                }
            }
        }
    } else {
        Write-Warning -Message "Get-O365PartnerRelationship - TenantID was not found in headers. Skipping."
    }
}