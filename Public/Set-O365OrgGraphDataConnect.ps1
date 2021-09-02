function Set-O365OrgGraphDataConnect {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .PARAMETER ServiceEnabled
    Parameter description

    .PARAMETER TenantLockBoxApproverGroup
    Group provided in form of email address. The email address must exists! Otherwise the api will break cmdlet

    .PARAMETER Force
    Forces the operation to run ignoring current settings. Useful to overwrite settings after breaking tenant :-)

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $ServiceEnabled,
        [string] $TenantLockBoxApproverGroup,
        [switch] $Force
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/o365dataplan"

    if ($TenantLockBoxApproverGroup -and $TenantLockBoxApproverGroup -notlike "*@*") {
        Write-Warning -Message "Set-O365OrgGraphDataConnect - TenantLockBoxApproverGroup must be given in email format, and it must exists."
        return
    }

    if (-not $Force) {
        $CurrentSettings = Get-O365OrgGraphDataConnect -Headers $Headers
        if ($CurrentSettings) {
            $Body = @{
                "ServiceEnabled"             = $CurrentSettings.ServiceEnabled
                "TenantLockBoxApproverGroup" = $CurrentSettings.TenantLockBoxApproverGroup
            }

            if ($null -ne $ServiceEnabled) {
                $Body.ServiceEnabled = $ServiceEnabled
            }
            if ($TenantLockBoxApproverGroup) {
                $Body.TenantLockBoxApproverGroup = $TenantLockBoxApproverGroup
            }
        }
    } else {
        $Body = @{
            "ServiceEnabled"             = $ServiceEnabled
            "TenantLockBoxApproverGroup" = $TenantLockBoxApproverGroup
        }
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
