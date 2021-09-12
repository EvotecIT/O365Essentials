function Get-O365AzureConditionalAccessTerms {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    # ?`$orderby=Name%20asc&`$filter=TypeId%20eq%208a76863a-a0e6-47a7-b99e-0410266eebcf
    # &x-tenantid=ceb371f6-8745-4876-a040-69f2d10a9d1a&{}&_=1631363067293
    $Uri = 'https://api.termsofuse.identitygovernance.azure.com/v1.1/Agreements'

    $QueryParameter = @{
        '$orderby'   = 'Name asc'
        '$filter'    = 'TypeId eq 8a76863a-a0e6-47a7-b99e-0410266eebcf'
        'x-tenantid' = $TenantID
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}