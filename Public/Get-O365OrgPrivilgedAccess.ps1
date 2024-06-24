function Get-O365OrgPrivilegedAccess {
    <#
        .SYNOPSIS
        Retrieves information about privileged access settings for the organization.
        .DESCRIPTION
        This function retrieves information about privileged access settings from the specified URI using the provided headers.
        .PARAMETER Headers
        Authentication token and additional information for the API request.
        .EXAMPLE
        Get-O365OrgPrivilegedAccess -Headers $headers
        .NOTES
        This function retrieves information about privileged access settings from the specified URI.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/tenantLockbox"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
