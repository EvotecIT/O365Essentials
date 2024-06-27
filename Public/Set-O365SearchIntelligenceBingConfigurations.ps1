function Set-O365SearchIntelligenceBingConfigurations {
    <#
    .SYNOPSIS
    Configures the Bing Extension feature for Office 365 Search Intelligence.

    .DESCRIPTION
    This function enables or disables the Bing Extension feature for Office 365 Search Intelligence. The Bing Extension enhances search results with Bing's web search capabilities. Additionally, it allows for limiting the extension to specific groups.

    .PARAMETER Headers
    A dictionary containing the authorization headers required for the request. This includes tokens and expiration information. You can obtain these headers by using the Connect-O365Admin function.

    .PARAMETER ServiceEnabled
    A boolean value indicating whether to enable or disable the Bing Extension feature. Set to $true to enable or $false to disable.

    .EXAMPLE
    Set-O365SearchIntelligenceBingConfigurations -Headers $headers -ServiceEnabled $true
    This example enables the Bing Extension feature for Office 365 Search Intelligence using the provided headers.

    .EXAMPLE
    Set-O365SearchIntelligenceBingConfigurations -Headers $headers -ServiceEnabled $false
    This example disables the Bing Extension feature for Office 365 Search Intelligence using the provided headers.

    .NOTES
    This function requires a valid connection to Office 365 and the necessary permissions to manage Search Intelligence settings. Ensure you have the appropriate credentials and authorization before running this function.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $ServiceEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/configuration/update"

    if ($PSBoundParameters.ContainsKey('ServiceEnabled')) {

        $CurrentSettings = Get-O365SearchIntelligenceBingConfigurations -Headers $Headers
        if ($CurrentSettings) {
            $Body = @{
                IsServiceEnabledStateChanged = $true
                # GUI only allows a single change to all services at once
                <#
                ServiceEnabled               = $CurrentSettings.ServiceEnabled               #: False
                People                       = $CurrentSettings.People                       #: False
                Groups                       = $CurrentSettings.Groups                       #: False
                Documents                    = $CurrentSettings.Documents                    #: False
                Yammer                       = $CurrentSettings.Yammer                       #: False
                Teams                        = $CurrentSettings.Teams                        #: False
#>
                ServiceEnabled               = $ServiceEnabled               #: False
                People                       = $ServiceEnabled                       #: False
                Groups                       = $ServiceEnabled                       #: False
                Documents                    = $ServiceEnabled                    #: False
                Yammer                       = $ServiceEnabled                       #: False
                Teams                        = $ServiceEnabled                        #: False
                SaveTenantSettings           = $true           #: True
            }

            $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
            $Output
        }
    }
}