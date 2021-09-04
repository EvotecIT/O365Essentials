function Get-O365OrgModernAuthentication {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .EXAMPLE
    Get-O365OrgModernAuthentication -Verbose

    .NOTES
    https://admin.microsoft.com/#/Settings/Services/:/Settings/L1/ModernAuthentication
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/modernAuth"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}