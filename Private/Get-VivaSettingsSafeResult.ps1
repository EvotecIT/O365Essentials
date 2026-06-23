function Get-VivaSettingsSafeResult {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $ResultName,
        [Parameter(Mandatory)][scriptblock] $ScriptBlock,
        [string] $UnavailableDescription = 'The Viva settings section did not return a usable payload.',
        [string] $UnavailableReason = 'TenantSpecific',
        [string] $UnavailableSuggestedAction = 'Verify the tenant has the required feature enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.',
        [bool] $UnavailableIsOptional = $false
    )

    try {
        $Result = & $ScriptBlock
        if ($null -eq $Result) {
            New-O365UnavailableResult -Name $ResultName -Area 'Viva settings section' -Description $UnavailableDescription -Reason $UnavailableReason -SuggestedAction $UnavailableSuggestedAction -IsOptional $UnavailableIsOptional
        }
        else {
            $Result
        }
    }
    catch {
        New-O365UnavailableResult -Name $ResultName -Area 'Viva settings section' -Description $UnavailableDescription -Reason $UnavailableReason -SuggestedAction $UnavailableSuggestedAction -ErrorMessage $_.Exception.Message -IsOptional $UnavailableIsOptional
    }
}
