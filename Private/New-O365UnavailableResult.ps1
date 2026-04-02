function New-O365UnavailableResult {
    <#
    .SYNOPSIS
    Creates a structured placeholder for unavailable internal admin payloads.

    .DESCRIPTION
    Returns a consistent object when a tenant-specific or partially captured admin
    endpoint does not return usable data.
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $Description,
        [string] $Area = 'Internal admin payload',
        [string] $Reason = 'TenantSpecific',
        [string] $ErrorMessage,
        [string] $SuggestedAction = 'Verify the tenant has the required feature enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.',
        [bool] $IsOptional = $false
    )

    $Result = [PSCustomObject] @{
        Name            = $Name
        Description     = $Description
        Area            = $Area
        Reason          = $Reason
        ErrorMessage    = $ErrorMessage
        SuggestedAction = $SuggestedAction
        DataBacked      = $false
        IsUnavailable   = $true
        IsOptional      = $IsOptional
    }

    $Result.PSObject.TypeNames.Insert(0, 'O365Essentials.UnavailableResult')
    $Result
}
