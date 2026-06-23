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
            Invoke-O365SectionSafeResult -Section PayAsYouGo -ResultName 'DataLocationAndCommitments' -ScriptBlock { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/tenant/datalocationandcommitments' -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders }
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
