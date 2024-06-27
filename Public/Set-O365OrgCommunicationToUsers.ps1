function Set-O365OrgCommunicationToUsers {
    <#
    .SYNOPSIS
    Configures the communication settings for end users in an Office 365 organization.

    .DESCRIPTION
    This function allows you to enable or disable communication services for end users in your Office 365 organization.
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER ServiceEnabled
    Specifies whether the communication service should be enabled for end users.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgCommunicationToUsers -Headers $headers -ServiceEnabled $true

    This example enables the communication service for end users in the Office 365 organization.

    .NOTES
    This function sends a POST request to the Office 365 admin API with the specified settings.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $ServiceEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/EndUserCommunications"

    $Body = @{
        ServiceEnabled = $ServiceEnabled
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body #-WhatIf:$WhatIfPreference.IsPresent
    $Output
}
