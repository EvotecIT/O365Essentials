function Get-O365SearchIntelligenceAdvanced {
    <#
    .SYNOPSIS
    Retrieves advanced Search Intelligence settings from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal search administration payloads exposed by searchadminapi endpoints,
    complementing the simpler Search Intelligence cmdlets already present in O365Essentials.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which advanced Search Intelligence payload to return.

    .PARAMETER QnasServiceType
    Service type used for the QnAs POST payload.

    .PARAMETER QnasFilter
    Filter value used for the QnAs POST payload.

    .EXAMPLE
    Get-O365SearchIntelligenceAdvanced -Name ConfigurationSettings

    .EXAMPLE
    Get-O365SearchIntelligenceAdvanced -Name Qnas -QnasServiceType Bing -QnasFilter Published
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'ConfigurationSettings', 'Configurations', 'FirstRunExperience', 'ModernResultTypes', 'News', 'NewsIndustry', 'NewsMsbEnabled', 'NewsOptions', 'Pivots', 'Qnas', 'UdtConnectorsSummary')][string] $Name = 'All',
        [string] $QnasServiceType = 'Bing',
        [string] $QnasFilter = 'Published'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context MicrosoftSearch -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $Headers.AjaxSessionKey -PortalRouteKey $Headers.PortalRouteKey
    $HasPortalSessionContext = $false
    if ($Headers) {
        if ($Headers.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($Headers['AjaxSessionKey'])) {
            $HasPortalSessionContext = $true
        }
        elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $HasPortalSessionContext = $true
        }
    }

    switch ($Name) {
        'All' {
            [PSCustomObject] @{
                ConfigurationSettings = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name ConfigurationSettings
                Configurations        = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name Configurations
                FirstRunExperience    = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name FirstRunExperience
                ModernResultTypes     = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name ModernResultTypes
                News                  = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name News
                Pivots                = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name Pivots
                Qnas                  = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name Qnas -QnasServiceType $QnasServiceType -QnasFilter $QnasFilter
                UdtConnectorsSummary  = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name UdtConnectorsSummary
            }
            return
        }
        'Configurations' {
            $FallbackResult = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name ConfigurationSettings
            if (-not (Test-O365UnavailableResult -InputObject $FallbackResult)) {
                return New-SearchFallbackResult -Result $FallbackResult -RequestedName 'Configurations' -FallbackName 'ConfigurationSettings'
            }
            $FallbackResult
            return
        }
        'ConfigurationSettings' {
            Invoke-O365SectionSafeResult -Section SearchAdvanced -ResultName 'ConfigurationSettings' -ScriptBlock { Get-SearchLeaf -Uri 'https://admin.cloud.microsoft/admin/api/searchadminapi/ConfigurationSettings' }
            return
        }
        'FirstRunExperience' {
            $Body = @(
                'SearchHomepageBannerFirstTime'
                'SearchHomepageBannerReturning'
                'SearchHomepageLearningFeedback'
                'SearchHomepageAnalyticsFirstTime'
                'SearchHomepageAnalyticsReturning'
            )
            Invoke-O365SectionSafeResult -Section SearchAdvanced -ResultName 'FirstRunExperience' -ScriptBlock { Get-SearchLeaf -Uri 'https://admin.cloud.microsoft/admin/api/searchadminapi/firstrunexperience/get' -Method POST -Body $Body }
            return
        }
        'Qnas' {
            $Body = @{
                ServiceType = $QnasServiceType
                Filter      = $QnasFilter
            }
            Invoke-O365SectionSafeResult -Section SearchAdvanced -ResultName 'Qnas' -ScriptBlock { Get-SearchLeaf -Uri 'https://admin.cloud.microsoft/admin/api/searchadminapi/Qnas' -Method POST -Body $Body -QuietOnError }
            return
        }
        'News' {
            [PSCustomObject] @{
                NewsOptions    = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name NewsOptions
                NewsIndustry   = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name NewsIndustry
                NewsMsbEnabled = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name NewsMsbEnabled
            }
            return
        }
    }

    $Uri = switch ($Name) {
        'ModernResultTypes' { 'https://admin.cloud.microsoft/admin/api/searchadminapi/modernResultTypes' }
        'NewsIndustry' { 'https://admin.cloud.microsoft/admin/api/searchadminapi/news/industry/Bing' }
        'NewsMsbEnabled' { 'https://admin.cloud.microsoft/admin/api/searchadminapi/news/msbenabled/Bing' }
        'NewsOptions' { 'https://admin.cloud.microsoft/admin/api/searchadminapi/news/options/Bing' }
        'Pivots' { 'https://admin.cloud.microsoft/admin/api/searchadminapi/Pivots' }
        'UdtConnectorsSummary' { 'https://admin.cloud.microsoft/admin/api/searchadminapi/UDTConnectorsSummary' }
    }

    Invoke-O365SectionSafeResult -Section SearchAdvanced -ResultName $Name -ScriptBlock { Get-SearchLeaf -Uri $Uri }
}
