function Get-O365OrgPeopleSettings {
    <#
    .SYNOPSIS
    Retrieves People settings used by the Microsoft 365 admin center.

    .DESCRIPTION
    Reads profile card properties, connector properties, pronouns, and name pronunciation
    settings from internal People admin APIs.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which People settings payload to return.

    .EXAMPLE
    Get-O365OrgPeopleSettings

    .EXAMPLE
    Get-O365OrgPeopleSettings -Name Pronouns
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'ConnectorProperties', 'NamePronunciation', 'ProfileCardProperties', 'Pronouns')][string] $Name = 'All'
    )

    $Headers = Connect-O365Admin -Headers $Headers
    if (-not $Headers) {
        Write-Warning "Get-O365OrgPeopleSettings - Authorization error. Returning unavailable result."
        return New-O365UnavailableResult -Name $Name -Area 'People settings section' -Description 'The People settings section could not resolve authorization context.' -Reason 'AuthorizationError' -SuggestedAction 'Reconnect with Connect-O365Admin and try again.'
    }

    $TenantID = if ($Headers.Tenant) { $Headers.Tenant } elseif ($Script:AuthorizationO365Cache.Tenant) { $Script:AuthorizationO365Cache.Tenant }
    if (-not $TenantID) {
        Write-Warning "Get-O365OrgPeopleSettings - TenantID was not found in headers. Returning unavailable result."
        return New-O365UnavailableResult -Name $Name -Area 'People settings section' -Description 'The People settings section could not resolve the tenant identifier required by the internal endpoint.' -Reason 'MissingTenantId' -SuggestedAction 'Reconnect with Connect-O365Admin so the tenant context is available.'
    }

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context People

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            ProfileCardProperties = Get-O365OrgPeopleSettings -Headers $Headers -Name ProfileCardProperties
            ConnectorProperties   = Get-O365OrgPeopleSettings -Headers $Headers -Name ConnectorProperties
            NamePronunciation     = Get-O365OrgPeopleSettings -Headers $Headers -Name NamePronunciation
            Pronouns              = Get-O365OrgPeopleSettings -Headers $Headers -Name Pronouns
        }
        return
    }

    $Uri = switch ($Name) {
        'ProfileCardProperties' { "https://admin.microsoft.com/fd/peopleadminservice/$TenantID/profilecard/properties" }
        'ConnectorProperties' { "https://admin.microsoft.com/fd/peopleadminservice/$TenantID/connectorProperties" }
        'NamePronunciation' { "https://admin.microsoft.com/fd/peopleadminservice/$TenantID/settings/namePronunciation" }
        'Pronouns' { "https://admin.microsoft.com/fd/peopleadminservice/$TenantID/settings/pronouns" }
    }

    Invoke-O365SectionSafeResult -Section People -ResultName $Name -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders }
}
