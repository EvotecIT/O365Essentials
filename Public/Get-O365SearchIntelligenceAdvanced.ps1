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
        } elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $HasPortalSessionContext = $true
        }
    }

    function Get-SearchLeaf {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Uri,
            [ValidateSet('GET', 'POST')][string] $Method = 'GET',
            [object] $Body,
            [switch] $QuietOnError
        )

        $Splat = @{
            Uri               = $Uri
            Headers           = $Headers
            Method            = $Method
            AdditionalHeaders = $AdditionalHeaders
        }
        if ($Method -eq 'POST') {
            $Splat['ContentType'] = 'application/json'
        }
        if ($HasPortalSessionContext) {
            $Splat['UsePortalSession'] = $true
        }
        if ($PSBoundParameters.ContainsKey('Body')) {
            $Splat['Body'] = $Body
        }
        if ($QuietOnError) {
            $Splat['QuietOnError'] = $true
        } else {
            $Splat['QuietOnError'] = $true
        }
        Invoke-O365Admin @Splat
    }

    function New-SearchUnavailableResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [string] $ErrorMessage
        )

        $Reason = 'TenantSpecific'
        $Description = 'The Search Intelligence advanced section did not return a usable payload.'
        $SuggestedAction = 'Verify the tenant has Microsoft Search features enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.'
        $IsOptional = $false

        if (-not $HasPortalSessionContext -or $ErrorMessage -match '\b440\b') {
            $Reason = 'PortalSessionRequired'
            $Description = 'The Search Intelligence advanced section appears to require an authenticated admin.cloud.microsoft portal session with AjaxSessionKey or portal cookies in addition to bearer-token auth.'
            $SuggestedAction = 'Replay the request through a validated admin.cloud.microsoft portal session or supply portal session state before retrying this Search surface.'
        }

        if ($ResultName -eq 'Qnas') {
            $IsOptional = $true
            if ($Reason -eq 'PortalSessionRequired') {
                $Description = 'The Search QnAs feed appears to require an authenticated admin.cloud.microsoft portal session with AjaxSessionKey or portal cookies. This feed can also be absent in tenants without published Bing QnAs.'
                $SuggestedAction = 'Validate only if Search QnAs are expected in this tenant, and prefer a replay that includes portal session state.'
            } else {
                $Description = 'The Search QnAs feed did not return data. This can be normal for tenants without published Bing QnAs.'
                $SuggestedAction = 'Validate only if Search QnAs are expected in this tenant.'
            }
        }

        New-O365UnavailableResult -Name $ResultName -Area 'Search Intelligence advanced section' -Description $Description -Reason $Reason -ErrorMessage $ErrorMessage -SuggestedAction $SuggestedAction -IsOptional $IsOptional
    }

    function Get-SearchSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-SearchUnavailableResult -ResultName $ResultName
            } else {
                $Result
            }
        } catch {
            New-SearchUnavailableResult -ResultName $ResultName -ErrorMessage $_.Exception.Message
        }
    }

    function New-SearchFallbackResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)] $Result,
            [Parameter(Mandatory)][string] $RequestedName,
            [Parameter(Mandatory)][string] $FallbackName
        )

        if ($Result -is [psobject] -and $Result -isnot [string] -and $Result -isnot [ValueType]) {
            $FallbackResult = $Result | Select-Object *
            $FallbackResult | Add-Member -NotePropertyName RequestedName -NotePropertyValue $RequestedName -Force
            $FallbackResult | Add-Member -NotePropertyName FallbackName -NotePropertyValue $FallbackName -Force
            $FallbackResult | Add-Member -NotePropertyName FallbackUsed -NotePropertyValue $true -Force
            $FallbackResult | Add-Member -NotePropertyName FallbackDescription -NotePropertyValue 'The Configurations endpoint did not return usable data, so ConfigurationSettings was returned instead.' -Force
            return $FallbackResult
        }

        [pscustomobject]@{
            RequestedName       = $RequestedName
            FallbackName        = $FallbackName
            FallbackUsed        = $true
            FallbackDescription = 'The Configurations endpoint did not return usable data, so ConfigurationSettings was returned instead.'
            Result              = $Result
        }
    }

    switch ($Name) {
        'All' {
            [PSCustomObject] @{
                ConfigurationSettings = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name ConfigurationSettings
                Configurations       = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name Configurations
                FirstRunExperience   = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name FirstRunExperience
                ModernResultTypes    = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name ModernResultTypes
                News                 = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name News
                Pivots               = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name Pivots
                Qnas                 = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name Qnas -QnasServiceType $QnasServiceType -QnasFilter $QnasFilter
                UdtConnectorsSummary = Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name UdtConnectorsSummary
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
            Get-SearchSafeResult -ResultName 'ConfigurationSettings' -ScriptBlock { Get-SearchLeaf -Uri 'https://admin.cloud.microsoft/admin/api/searchadminapi/ConfigurationSettings' }
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
            Get-SearchSafeResult -ResultName 'FirstRunExperience' -ScriptBlock { Get-SearchLeaf -Uri 'https://admin.cloud.microsoft/admin/api/searchadminapi/firstrunexperience/get' -Method POST -Body $Body }
            return
        }
        'Qnas' {
            $Body = @{
                ServiceType = $QnasServiceType
                Filter      = $QnasFilter
            }
            Get-SearchSafeResult -ResultName 'Qnas' -ScriptBlock { Get-SearchLeaf -Uri 'https://admin.cloud.microsoft/admin/api/searchadminapi/Qnas' -Method POST -Body $Body -QuietOnError }
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

    Get-SearchSafeResult -ResultName $Name -ScriptBlock { Get-SearchLeaf -Uri $Uri }
}
