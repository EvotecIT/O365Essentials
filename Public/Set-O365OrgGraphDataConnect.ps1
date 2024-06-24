function Set-O365OrgGraphDataConnect {
    <#
    .SYNOPSIS
    Configures the settings for Office 365 Organizational Graph Data Connect.

    .DESCRIPTION
    This function allows you to configure the settings for Office 365 Organizational Graph Data Connect. 
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER ServiceEnabled
    Specifies whether the Organizational Graph Data Connect service should be enabled or disabled.

    .PARAMETER TenantLockBoxApproverGroup
    Specifies the email address of the group that will act as the Tenant LockBox approver. The email address must exist; otherwise, the API will break the cmdlet.

    .PARAMETER Force
    Forces the operation to run, ignoring current settings. Useful to overwrite settings after breaking tenant.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgGraphDataConnect -Headers $headers -ServiceEnabled $true -TenantLockBoxApproverGroup "approver@example.com" -Force

    This example enables the Organizational Graph Data Connect service, sets the Tenant LockBox approver group to "approver@example.com", and forces the operation to run.

    .NOTES
    Ensure that the TenantLockBoxApproverGroup email address is valid and exists in your organization to avoid errors.
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
