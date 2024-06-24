function Get-O365OrgPrivacyProfile {
    <#
        .SYNOPSIS
        Retrieves information about the organization's privacy policy.
        .DESCRIPTION
        This function retrieves information about the organization's privacy policy from the specified URI using the provided headers.
        .PARAMETER Headers
        Authentication token and additional information for the API request.
        .EXAMPLE
        Get-O365OrgPrivacyProfile -Headers $headers
        .NOTES
        This function retrieves information about the organization's privacy policy from the specified URI.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/privacypolicy"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
