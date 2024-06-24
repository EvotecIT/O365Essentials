function Get-O365OrgOrganizationInformation {
    <#
        .SYNOPSIS
        Retrieves organization information from the specified URI.
        .DESCRIPTION
        This function retrieves organization information from the specified URI using the provided headers.
        .PARAMETER Headers
        Authentication token and additional information for the API request.
        .PARAMETER NoTranslation
        Specifies whether to skip translation.
        .EXAMPLE
        Get-O365OrgOrganizationInformation -Headers $headers -NoTranslation
        .NOTES
        This function retrieves organization information from the specified URI.
    #>
    [alias('Get-O365OrgCompanyInformation')]
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/profile"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($NoTranslation) {
        $Output
    } else {
        $Output
    }
}
