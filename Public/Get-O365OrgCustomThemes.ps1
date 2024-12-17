function Get-O365OrgCustomThemes {
    <#
    .SYNOPSIS
    Retrieves custom themes information for the organization.

    .DESCRIPTION
    This function retrieves custom themes information for the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    Specifies the headers containing the authorization information.

    .EXAMPLE
    Get-O365OrgCustomThemes -Headers $Headers
    An example of how to retrieve custom themes information.

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/theme/v2"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output.ThemeData
}
