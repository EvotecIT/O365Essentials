function Set-O365SearchIntelligenceBingConfigurations {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $ServiceEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/configuration/update"

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