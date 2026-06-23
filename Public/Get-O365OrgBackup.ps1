function Get-O365OrgBackup {
    <#
    .SYNOPSIS
    Retrieves Microsoft 365 Backup data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Microsoft 365 Backup payloads used by the billing, subscription,
    and enhanced restore configuration experiences in the Microsoft 365 admin center.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Microsoft 365 Backup payload to return.

    .EXAMPLE
    Get-O365OrgBackup

    .EXAMPLE
    Get-O365OrgBackup -Name AzureSubscriptionPermissions

    .EXAMPLE
    Get-O365OrgBackup -Name EnhancedRestoreStatus
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'AzureSubscriptionPermissions', 'AzureSubscriptions', 'BillingFeature', 'EnhancedRestoreFeature', 'EnhancedRestoreStatus')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Backup

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            BillingFeature               = Get-O365OrgBackup -Headers $Headers -Name BillingFeature
            AzureSubscriptions           = Get-O365OrgBackup -Headers $Headers -Name AzureSubscriptions
            AzureSubscriptionPermissions = Get-O365OrgBackup -Headers $Headers -Name AzureSubscriptionPermissions
            EnhancedRestoreFeature       = Get-O365OrgBackup -Headers $Headers -Name EnhancedRestoreFeature
            EnhancedRestoreStatus        = Get-O365OrgBackup -Headers $Headers -Name EnhancedRestoreStatus
        }
        return
    }

    switch ($Name) {
        'AzureSubscriptionPermissions' {
            @(Get-AzureSubscriptionPermissions)
            return
        }
        'AzureSubscriptions' {
            Invoke-O365SectionSafeResult -Section Backup -ResultName 'AzureSubscriptions' -ScriptBlock { Get-BackupLeaf -Uri 'https://admin.microsoft.com/admin/api/syntexbilling/azureSubscriptions' }
            return
        }
        'BillingFeature' {
            Invoke-O365SectionSafeResult -Section Backup -ResultName 'BillingFeature' -ScriptBlock { Get-BackupLeaf -Uri "https://admin.microsoft.com/_api/v2.1/billingFeatures('M365Backup')" }
            return
        }
        'EnhancedRestoreFeature' {
            Invoke-O365SectionSafeResult -Section Backup -ResultName 'EnhancedRestoreFeature' -ScriptBlock { Get-BackupLeaf -Uri 'https://admin.microsoft.com/fd/enhancedRestorev2/v1/featureSetting' }
            return
        }
        'EnhancedRestoreStatus' {
            Get-EnhancedRestoreStatus
            return
        }
    }
}
