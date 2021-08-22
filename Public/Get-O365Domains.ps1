function Get-O365Domains {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    #$Uri = "https://admin.microsoft.com/admin/api/Domains/List?filter=&searchText=&computeDomainRegistrationData=true"
    $Uri = "https://admin.microsoft.com/admin/api/Domains/List"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}