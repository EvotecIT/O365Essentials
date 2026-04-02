function Get-O365ContentUnderstanding {
    <#
    .SYNOPSIS
    Retrieves Content Understanding settings from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Content Understanding payloads used by the pay-as-you-go and
    content-processing settings experiences in the Microsoft 365 admin center.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Content Understanding payload to return.

    .EXAMPLE
    Get-O365ContentUnderstanding

    .EXAMPLE
    Get-O365ContentUnderstanding -Name Setting
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'AutoFill', 'BillingSettings', 'ESignature', 'ImageTagging', 'Licensing', 'PlaybackTranscriptTranslation', 'PowerAppsEnvironments', 'Setting', 'TaxonomyTagging')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context PayAsYouGo

    function Get-ContentUnderstandingSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Content Understanding section' -Description 'The Content Understanding section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Content Understanding section' -Description 'The Content Understanding section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            Setting                       = Get-O365ContentUnderstanding -Headers $Headers -Name Setting
            BillingSettings               = Get-O365ContentUnderstanding -Headers $Headers -Name BillingSettings
            AutoFill                      = Get-O365ContentUnderstanding -Headers $Headers -Name AutoFill
            Licensing                     = Get-O365ContentUnderstanding -Headers $Headers -Name Licensing
            ImageTagging                  = Get-O365ContentUnderstanding -Headers $Headers -Name ImageTagging
            ESignature                    = Get-O365ContentUnderstanding -Headers $Headers -Name ESignature
            TaxonomyTagging               = Get-O365ContentUnderstanding -Headers $Headers -Name TaxonomyTagging
            PlaybackTranscriptTranslation = Get-O365ContentUnderstanding -Headers $Headers -Name PlaybackTranscriptTranslation
            PowerAppsEnvironments         = Get-O365ContentUnderstanding -Headers $Headers -Name PowerAppsEnvironments
        }
        return
    }

    $Uri = switch ($Name) {
        'AutoFill' { 'https://admin.microsoft.com/admin/api/contentunderstanding/autofillsetting' }
        'BillingSettings' { 'https://admin.microsoft.com/admin/api/contentunderstanding/billingSettings' }
        'ESignature' { 'https://admin.microsoft.com/admin/api/contentunderstanding/esignaturesettings' }
        'ImageTagging' { 'https://admin.microsoft.com/admin/api/contentunderstanding/imagetaggingsetting' }
        'Licensing' { 'https://admin.microsoft.com/admin/api/contentunderstanding/licensing' }
        'PlaybackTranscriptTranslation' { 'https://admin.microsoft.com/admin/api/contentunderstanding/playbacktranscripttranslationsettings' }
        'PowerAppsEnvironments' { 'https://admin.microsoft.com/admin/api/contentunderstanding/powerAppsEnvironments' }
        'Setting' { 'https://admin.microsoft.com/admin/api/contentunderstanding/setting' }
        'TaxonomyTagging' { 'https://admin.microsoft.com/admin/api/contentunderstanding/taxonomytaggingsetting' }
    }

    Get-ContentUnderstandingSafeResult -ResultName $Name -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders }
}
