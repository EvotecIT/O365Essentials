function Get-PayAsYouGoTelemetryInfo {
    [PSCustomObject] @{
        Name               = 'Telemetry'
        RequestMethod      = 'POST'
        RequestPath        = '/admin/api/km/setting/telemetry'
        ObservedStatusCode = 204
        PortalSurface      = 'Org settings / Pay-as-you-go services'
        WriteOnly          = $true
        SupportsDirectRead = $false
        EndpointObserved   = $true
        DataBacked         = $true
        Description        = 'The telemetry route is a write-only admin portal event stream. It records page and wizard actions and intentionally returns no payload.'
        SuggestedAction    = 'Do not treat this route as a read failure. Use the captured request templates only if you explicitly need to emulate portal telemetry events.'
        ObservedTemplates  = @(
            [PSCustomObject] @{
                PageId        = 'CUWizardPage_BillToAzure'
                Action        = 'Get'
                Result        = 'GetAzureSubscriptionsSuccess'
                TimeSpent     = 0
                ActionDetails = [PSCustomObject] @{
                    selectedSubscriptionId    = ''
                    providerRegistrationState = ''
                }
            }
            [PSCustomObject] @{
                PageId        = 'CUWizardPage_BillToAzure'
                Action        = 'Get'
                Result        = 'GetIsCUFeatureCompletedSuccess'
                TimeSpent     = 0
                ActionDetails = [PSCustomObject] @{
                    selectedSubscriptionId    = ''
                    providerRegistrationState = ''
                }
            }
            [PSCustomObject] @{
                PageId        = 'ContentUnderstandingSetupPage'
                Action        = 'Get'
                Result        = 'Success'
                ActionDetails = [PSCustomObject] @{
                    imageTagOption                        = 'off'
                    imageTagSitesFromCSV                  = 0
                    imageTagSitesFromPicker               = 0
                    formProcessingOption                  = 'enableAllSites'
                    sitesCountFromPicker                  = 0
                    sitesCountFromCSV                     = 0
                    powerAppsEnvironmentCount             = 0
                    isDefaultPowerAppsEnvironmentSelected = $true
                    Title                                 = ''
                    Url                                   = ''
                    oCROption                             = 'disable'
                    oCRSitesCountFromPicker               = 0
                    oCRSitesCountFromCSV                  = 0
                    taxonomyTaggingOption                 = 'enableAllSites'
                    taxonomyTaggingSitesFromPicker        = 0
                    taxonomyTaggingSitesFromCSV           = 0
                    eSignatureStatus                      = 'disabled'
                    eSignatureSitesChoiceOption           = 'enableAllSites'
                    eSignatureSitesCountFromPicker        = 0
                    eSignatureSitesCountFromCSV           = 0
                    eSignatureDocuSignProviderStatus      = 'disabled'
                    eSignatureAdobeSignProviderStatus     = 'disabled'
                    eSignatureWordStatus                  = 'enabled'
                    archiveStatus                         = 'enabled'
                    unlicensedODBArchiveStatus            = 'enabled'
                }
            }
        )
    }
}
