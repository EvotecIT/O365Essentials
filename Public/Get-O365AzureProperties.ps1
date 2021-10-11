function Get-O365AzureProperties {
    <#
    .SYNOPSIS
    Reads the properties of Azure Active Directory (Azure AD) for the current tenant.

    .DESCRIPTION
    Reads the properties of Azure Active Directory (Azure AD) for the current tenant.

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER NoTranslation
    Return information as provided by API, rather than translated to only values visible in GUI

    .EXAMPLE
    Get-O365AzureProperties -Verbose

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/Directory'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            [PSCustomObject] @{
                DisplayName          = $Output.DisplayName
                NotificationLanguage = $Output.preferredLanguage
                TechnicalContact     = if ($Output.technicalNotificationMails.Count -gt 0) { $Output.technicalNotificationMails[0] } else { '' }
                GlobalPrivacyContact = $Output.privacyProfile.contactEmail
                PrivacyStatementURL  = $Output.privacyProfile.statementUrl
            }
        }
    }
}