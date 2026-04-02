function Get-O365PayAsYouGoService {
    <#
    .SYNOPSIS
    Retrieves pay-as-you-go service data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal pay-as-you-go payloads used by the Microsoft 365 admin center,
    including backup, data location commitments, and Content Understanding settings.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which pay-as-you-go payload to return.

    .EXAMPLE
    Get-O365PayAsYouGoService

    .EXAMPLE
    Get-O365PayAsYouGoService -Name DataLocationAndCommitments
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'AutoFill', 'AzureSubscriptions', 'BillingFeature', 'DataLocationAndCommitments', 'EnhancedRestoreFeature', 'ESignature', 'ImageTagging', 'Licensing', 'PlaybackTranscriptTranslation', 'PrimarySetting', 'TaxonomyTagging', 'Telemetry')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context PayAsYouGo

    function Get-PayAsYouGoTelemetryInfo {
        [PSCustomObject] @{
            Name                 = 'Telemetry'
            RequestMethod        = 'POST'
            RequestPath          = '/admin/api/km/setting/telemetry'
            ObservedStatusCode   = 204
            PortalSurface        = 'Org settings / Pay-as-you-go services'
            WriteOnly            = $true
            SupportsDirectRead   = $false
            EndpointObserved     = $true
            DataBacked           = $true
            Description          = 'The telemetry route is a write-only admin portal event stream. It records page and wizard actions and intentionally returns no payload.'
            SuggestedAction      = 'Do not treat this route as a read failure. Use the captured request templates only if you explicitly need to emulate portal telemetry events.'
            ObservedTemplates    = @(
                [PSCustomObject] @{
                    PageId        = 'CUWizardPage_BillToAzure'
                    Action        = 'Get'
                    Result        = 'GetAzureSubscriptionsSuccess'
                    TimeSpent     = 0
                    ActionDetails = [PSCustomObject] @{
                        selectedSubscriptionId   = ''
                        providerRegistrationState = ''
                    }
                }
                [PSCustomObject] @{
                    PageId        = 'CUWizardPage_BillToAzure'
                    Action        = 'Get'
                    Result        = 'GetIsCUFeatureCompletedSuccess'
                    TimeSpent     = 0
                    ActionDetails = [PSCustomObject] @{
                        selectedSubscriptionId   = ''
                        providerRegistrationState = ''
                    }
                }
                [PSCustomObject] @{
                    PageId        = 'ContentUnderstandingSetupPage'
                    Action        = 'Get'
                    Result        = 'Success'
                    ActionDetails = [PSCustomObject] @{
                        imageTagOption                     = 'off'
                        imageTagSitesFromCSV              = 0
                        imageTagSitesFromPicker           = 0
                        formProcessingOption              = 'enableAllSites'
                        sitesCountFromPicker              = 0
                        sitesCountFromCSV                 = 0
                        powerAppsEnvironmentCount         = 0
                        isDefaultPowerAppsEnvironmentSelected = $true
                        Title                              = ''
                        Url                                = ''
                        oCROption                          = 'disable'
                        oCRSitesCountFromPicker           = 0
                        oCRSitesCountFromCSV              = 0
                        taxonomyTaggingOption             = 'enableAllSites'
                        taxonomyTaggingSitesFromPicker    = 0
                        taxonomyTaggingSitesFromCSV       = 0
                        eSignatureStatus                  = 'disabled'
                        eSignatureSitesChoiceOption       = 'enableAllSites'
                        eSignatureSitesCountFromPicker    = 0
                        eSignatureSitesCountFromCSV       = 0
                        eSignatureDocuSignProviderStatus  = 'disabled'
                        eSignatureAdobeSignProviderStatus = 'disabled'
                        eSignatureWordStatus              = 'enabled'
                        archiveStatus                     = 'enabled'
                        unlicensedODBArchiveStatus        = 'enabled'
                    }
                }
            )
        }
    }

    function Get-PayAsYouGoSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Pay-as-you-go services section' -Description 'The pay-as-you-go services section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Pay-as-you-go services section' -Description 'The pay-as-you-go services section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    switch ($Name) {
        'All' {
            [PSCustomObject] @{
                BillingFeature                = Get-O365PayAsYouGoService -Headers $Headers -Name BillingFeature
                AzureSubscriptions            = Get-O365PayAsYouGoService -Headers $Headers -Name AzureSubscriptions
                EnhancedRestoreFeature        = Get-O365PayAsYouGoService -Headers $Headers -Name EnhancedRestoreFeature
                DataLocationAndCommitments    = Get-O365PayAsYouGoService -Headers $Headers -Name DataLocationAndCommitments
                PrimarySetting                = Get-O365PayAsYouGoService -Headers $Headers -Name PrimarySetting
                AutoFill                      = Get-O365PayAsYouGoService -Headers $Headers -Name AutoFill
                Licensing                     = Get-O365PayAsYouGoService -Headers $Headers -Name Licensing
                ImageTagging                  = Get-O365PayAsYouGoService -Headers $Headers -Name ImageTagging
                ESignature                    = Get-O365PayAsYouGoService -Headers $Headers -Name ESignature
                TaxonomyTagging               = Get-O365PayAsYouGoService -Headers $Headers -Name TaxonomyTagging
                PlaybackTranscriptTranslation = Get-O365PayAsYouGoService -Headers $Headers -Name PlaybackTranscriptTranslation
                Telemetry                     = Get-O365PayAsYouGoService -Headers $Headers -Name Telemetry
            }
            return
        }
        'BillingFeature' {
            Get-O365OrgBackup -Headers $Headers -Name BillingFeature
            return
        }
        'AzureSubscriptions' {
            Get-O365OrgBackup -Headers $Headers -Name AzureSubscriptions
            return
        }
        'EnhancedRestoreFeature' {
            Get-O365OrgBackup -Headers $Headers -Name EnhancedRestoreFeature
            return
        }
        'DataLocationAndCommitments' {
            Get-PayAsYouGoSafeResult -ResultName 'DataLocationAndCommitments' -ScriptBlock { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/tenant/datalocationandcommitments' -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders }
            return
        }
        'PrimarySetting' {
            Get-O365ContentUnderstanding -Headers $Headers -Name Setting
            return
        }
        'AutoFill' {
            Get-O365ContentUnderstanding -Headers $Headers -Name AutoFill
            return
        }
        'Licensing' {
            Get-O365ContentUnderstanding -Headers $Headers -Name Licensing
            return
        }
        'ImageTagging' {
            Get-O365ContentUnderstanding -Headers $Headers -Name ImageTagging
            return
        }
        'ESignature' {
            Get-O365ContentUnderstanding -Headers $Headers -Name ESignature
            return
        }
        'TaxonomyTagging' {
            Get-O365ContentUnderstanding -Headers $Headers -Name TaxonomyTagging
            return
        }
        'PlaybackTranscriptTranslation' {
            Get-O365ContentUnderstanding -Headers $Headers -Name PlaybackTranscriptTranslation
            return
        }
        'Telemetry' {
            Get-PayAsYouGoTelemetryInfo
            return
        }
    }
}
