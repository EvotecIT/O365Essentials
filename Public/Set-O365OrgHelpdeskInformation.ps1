function Set-O365OrgHelpdeskInformation {
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
    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/helpdesk"

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