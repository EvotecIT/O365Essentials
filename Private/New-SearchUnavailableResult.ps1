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
        }
        else {
            $Description = 'The Search QnAs feed did not return data. This can be normal for tenants without published Bing QnAs.'
            $SuggestedAction = 'Validate only if Search QnAs are expected in this tenant.'
        }
    }

    New-O365UnavailableResult -Name $ResultName -Area 'Search Intelligence advanced section' -Description $Description -Reason $Reason -ErrorMessage $ErrorMessage -SuggestedAction $SuggestedAction -IsOptional $IsOptional
}
