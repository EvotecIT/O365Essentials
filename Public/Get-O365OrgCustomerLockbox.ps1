function Get-O365OrgCustomerLockbox {
    <#
    .SYNOPSIS
    Retrieves customer lockbox information for the organization.

    .DESCRIPTION
    This function retrieves customer lockbox information for the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    Specifies the headers containing the authorization information.

    .EXAMPLE
    Get-O365OrgCustomerLockbox -Headers $Headers
    An example of how to retrieve customer lockbox information.

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/security/dataaccess"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
