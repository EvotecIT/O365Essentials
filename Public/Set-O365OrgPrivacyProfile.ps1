function Set-O365OrgPrivacyProfile {
    <#
        .SYNOPSIS
        Configures the privacy profile settings for an Office 365 organization.
        .DESCRIPTION
        This function updates the privacy profile settings for an Office 365 organization. It allows specifying the privacy statement URL and the privacy contact information.
        .PARAMETER Headers
        Specifies the headers for the API request. Typically includes authorization tokens.
        .PARAMETER PrivacyUrl
        Specifies the URL of the privacy statement. Accepts a URI value.
        .PARAMETER PrivacyContact
        Specifies the contact information for privacy-related inquiries. Accepts a string value.
        .EXAMPLE
        $headers = @{Authorization = "Bearer your_token"}
        Set-O365OrgPrivacyProfile -Headers $headers -PrivacyUrl "https://example.com/privacy" -PrivacyContact "privacy@example.com"

        This example sets the privacy statement URL to "https://example.com/privacy" and the privacy contact to "privacy@example.com".
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter()][uri] $PrivacyUrl,
        [parameter()][string] $PrivacyContact
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/privacypolicy"
    $Body = @{
        PrivacyStatement = $PrivacyUrl
        PrivacyContact   = $PrivacyContact
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
