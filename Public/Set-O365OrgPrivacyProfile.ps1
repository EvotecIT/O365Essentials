function Set-O365OrgPrivacyProfile {
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