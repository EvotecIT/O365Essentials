function Get-O365Domain {
    <#
    .SYNOPSIS
    Retrieves domain information from Office 365.

    .DESCRIPTION
    This function retrieves domain information from Office 365 using the specified API endpoint and headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365Domain -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    #$Uri = "https://admin.microsoft.com/admin/api/Domains/List?filter=&searchText=&computeDomainRegistrationData=true"
    $Uri = "https://admin.microsoft.com/admin/api/Domains/List"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
