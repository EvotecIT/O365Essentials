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

    function Get-BackupLeaf {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Uri
        )

        Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders
    }

    function Get-BackupSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Microsoft 365 Backup section' -Description 'The Microsoft 365 Backup section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Microsoft 365 Backup section' -Description 'The Microsoft 365 Backup section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    function Get-AzureSubscriptionPermissions {
        $AzureSubscriptions = @(Get-O365OrgBackup -Headers $Headers -Name AzureSubscriptions)
        if ($AzureSubscriptions.Count -eq 1 -and (Test-O365UnavailableResult -InputObject $AzureSubscriptions[0])) {
            return $AzureSubscriptions[0]
        }

        foreach ($Subscription in $AzureSubscriptions) {
            [PSCustomObject] @{
                SubscriptionId = $Subscription.subscriptionId
                DisplayName    = $Subscription.displayName
                Permissions    = Get-BackupSafeResult -ResultName ("AzureSubscriptionPermissions:{0}" -f $Subscription.subscriptionId) -ScriptBlock { Get-BackupLeaf -Uri ("https://admin.microsoft.com/admin/api/syntexbilling/azureSubscriptions/{0}/permissions" -f $Subscription.subscriptionId) }
            }
        }
    }

    function Get-EnhancedRestoreStatus {
        $BatchBody = @{
            requests = @(
                @{
                    id     = 'GetOffboardingSiteProtectionUnits'
                    method = 'GET'
                    url    = 'solutions/backupRestore/protectionUnits/microsoft.graph.siteProtectionUnit/$count?$filter=offboardRequestedDateTime gt 0001-01-01'
                },
                @{
                    id     = 'GetOffboardingDriveProtectionUnits'
                    method = 'GET'
                    url    = 'solutions/backupRestore/protectionUnits/microsoft.graph.driveProtectionUnit/$count?$filter=offboardRequestedDateTime gt 0001-01-01'
                },
                @{
                    id     = 'GetOffboardingMailboxProtectionUnits'
                    method = 'GET'
                    url    = 'solutions/backupRestore/protectionUnits/microsoft.graph.mailboxProtectionUnit/$count?$filter=offboardRequestedDateTime gt 0001-01-01'
                }
            )
        }

        $Result = Get-BackupSafeResult -ResultName 'EnhancedRestoreStatus' -ScriptBlock { Invoke-O365Admin -Uri 'https://graph.microsoft.com/beta/$batch' -Headers $Headers -Method POST -Body $BatchBody -AdditionalHeaders $AdditionalHeaders }
        if (Test-O365UnavailableResult -InputObject $Result) {
            return $Result
        }

        $ResponsesById = @{}
        foreach ($Response in @($Result.responses)) {
            $ResponsesById[$Response.id] = $Response
        }

        [PSCustomObject] @{
            SiteOffboardingCount    = if ($ResponsesById['GetOffboardingSiteProtectionUnits'] -and $ResponsesById['GetOffboardingSiteProtectionUnits'].status -eq 200) { [int] $ResponsesById['GetOffboardingSiteProtectionUnits'].body } else { $null }
            DriveOffboardingCount   = if ($ResponsesById['GetOffboardingDriveProtectionUnits'] -and $ResponsesById['GetOffboardingDriveProtectionUnits'].status -eq 200) { [int] $ResponsesById['GetOffboardingDriveProtectionUnits'].body } else { $null }
            MailboxOffboardingCount = if ($ResponsesById['GetOffboardingMailboxProtectionUnits'] -and $ResponsesById['GetOffboardingMailboxProtectionUnits'].status -eq 200) { [int] $ResponsesById['GetOffboardingMailboxProtectionUnits'].body } else { $null }
            RawResponses            = @($Result.responses)
        }
    }

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
            Get-BackupSafeResult -ResultName 'AzureSubscriptions' -ScriptBlock { Get-BackupLeaf -Uri 'https://admin.microsoft.com/admin/api/syntexbilling/azureSubscriptions' }
            return
        }
        'BillingFeature' {
            Get-BackupSafeResult -ResultName 'BillingFeature' -ScriptBlock { Get-BackupLeaf -Uri "https://admin.microsoft.com/_api/v2.1/billingFeatures('M365Backup')" }
            return
        }
        'EnhancedRestoreFeature' {
            Get-BackupSafeResult -ResultName 'EnhancedRestoreFeature' -ScriptBlock { Get-BackupLeaf -Uri 'https://admin.microsoft.com/fd/enhancedRestorev2/v1/featureSetting' }
            return
        }
        'EnhancedRestoreStatus' {
            Get-EnhancedRestoreStatus
            return
        }
    }
}
