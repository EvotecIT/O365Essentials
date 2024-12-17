function Get-O365OrgModernAuthentication {
    <#
    .SYNOPSIS
    Provides information about modern authentication for Office 365.

    .DESCRIPTION
    This function retrieves details about modern authentication for Office 365 from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365OrgModernAuthentication -Verbose

    .NOTES
    For more information, visit: https://admin.microsoft.com/#/Settings/Services/:/Settings/L1/ModernAuthentication
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/modernAuth"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
