function Get-O365AzureEnterpriseAppsGroupConsent {
    # https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://graph.microsoft.com/beta/settings'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            ($Output | Where-Object { $_.displayName -eq 'Consent Policy Settings' }).values
        } else {
            $ConsentPolicy = $Output | Where-Object { $_.displayName -eq 'Consent Policy Settings' }
            if ($ConsentPolicy) {
                $Object = [PSCustomObject] @{
                    EnableGroupSpecificConsent                      = ($ConsentPolicy.values | Where-Object { $_.name -eq 'EnableGroupSpecificConsent' } | Select-Object -ExpandProperty value)
                    BlockUserConsentForRiskyApps                    = $ConsentPolicy.values | Where-Object { $_.name -eq 'BlockUserConsentForRiskyApps' } | Select-Object -ExpandProperty value
                    EnableAdminConsentRequests                      = $ConsentPolicy.values | Where-Object { $_.name -eq 'EnableAdminConsentRequests' } | Select-Object -ExpandProperty value
                    ConstrainGroupSpecificConsentToMembersOfGroupId = $ConsentPolicy.values | Where-Object { $_.name -eq 'ConstrainGroupSpecificConsentToMembersOfGroupId' } | Select-Object -ExpandProperty value
                }
                if ($Object.EnableGroupSpecificConsent -eq 'true') {
                    $Object.EnableGroupSpecificConsent = $true
                } else {
                    $Object.EnableGroupSpecificConsent = $false
                }

                if ($Object.BlockUserConsentForRiskyApps -eq 'true') {
                    $Object.BlockUserConsentForRiskyApps = $true
                } else {
                    $Object.BlockUserConsentForRiskyApps = $false
                }
                if ($Object.EnableAdminConsentRequests -eq 'true') {
                    $Object.EnableAdminConsentRequests = $true
                } else {
                    $Object.EnableAdminConsentRequests = $false
                }
                $Object
            }
        }
    }
}