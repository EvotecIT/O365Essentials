function Set-O365OrgHelpdeskInformation {
    <#
    .SYNOPSIS
    Configures the help desk information for an Office 365 organization.

    .DESCRIPTION
    This function allows you to configure the help desk information for your Office 365 organization. 
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER CustomHelpDeskInformationEnabled
    Specifies whether custom help desk information should be enabled.

    .PARAMETER Title
    Specifies the title of the custom help desk information.

    .PARAMETER PhoneNumber
    Specifies the phone number for the help desk.

    .PARAMETER EmailAddress
    Specifies the email address for the help desk.

    .PARAMETER SupportUrl
    Specifies the URL for the help desk support.

    .PARAMETER SupportUrlTitle
    Specifies the title for the support URL.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgHelpdeskInformation -Headers $headers -CustomHelpDeskInformationEnabled $true -Title "Support Center" -PhoneNumber "123-456-7890" -EmailAddress "support@example.com" -SupportUrl "https://support.example.com" -SupportUrlTitle "Visit Support"

    This example enables custom help desk information, sets the title to "Support Center", phone number to "123-456-7890", email address to "support@example.com", support URL to "https://support.example.com", and support URL title to "Visit Support" for the Office 365 organization.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [alias('Enabled')][bool] $CustomHelpDeskInformationEnabled,
        [string] $Title,
        [string] $PhoneNumber,
        [string] $EmailAddress,
        [string] $SupportUrl,
        [string] $SupportUrlTitle
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/helpdesk"

    $CurrentSettings = Get-O365OrgHelpdeskInformation -Headers $Headers
    if ($CurrentSettings) {

        $Body = @{
            "CustomSupportEnabled" = $CurrentSettings.CustomSupportEnabled
            "Title"                = $CurrentSettings.Title

            "PhoneEnabled"         = $CurrentSettings.PhoneEnabled
            "PhoneNumber"          = $CurrentSettings.PhoneNumber

            "EmailEnabled"         = $CurrentSettings.EmailEnabled
            "EmailAddress"         = $CurrentSettings.EmailAddress

            "UrlEnabled"           = $CurrentSettings.UrlEnabled
            "SupportUrl"           = $CurrentSettings.SupportUrl
            "SupportUrlTitle"      = $CurrentSettings.SupportUrlTitle
        }

        if ($PSBoundParameters.ContainsKey('CustomHelpDeskInformationEnabled')) {
            $Body.CustomSupportEnabled = $CustomHelpDeskInformationEnabled
        }
        if ($PSBoundParameters.ContainsKey('Title')) {
            $Body.Title = $Title
        }
        if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
            $Body.PhoneNumber = $PhoneNumber
            $Body.PhoneEnabled = if ($PhoneNumber) { $true } else { $false }
        }
        if ($PSBoundParameters.ContainsKey('EmailAddress')) {
            $Body.EmailEnabled = if ($EmailAddress) { $true } else { $false }
            $Body.EmailAddress = $EmailAddress
        }
        if ($PSBoundParameters.ContainsKey('SupportUrl')) {
            $Body.SupportUrlTitle = $SupportUrlTitle
            $Body.SupportUrl = $SupportUrl
            $Body.UrlEnabled = if ($SupportUrl) { $true } else { $false }
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}