function Set-O365AzureGroupExpiration {
    <#
    .SYNOPSIS
    Sets the expiration settings for Office 365 Azure groups.

    .DESCRIPTION
    This function configures the lifecycle management settings for Office 365 Azure groups, including setting the group lifetime, specifying which groups are managed, and configuring admin notification emails.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER GroupLifeTime
    Specifies the lifetime of the group in days. Accepts 180 or 365 days, or a custom value.

    .PARAMETER ExpirationEnabled
    Determines the scope of groups for which expiration is enabled. Valid values are 'None', 'Selected', 'All'.

    .PARAMETER AdminNotificationEmails
    Specifies the email addresses for sending notifications about group expiration events.

    .PARAMETER ExpirationGroups
    Specifies the display names of groups for which expiration settings are to be applied. This parameter is used when ExpirationEnabled is set to 'Selected'.

    .PARAMETER ExpirationGroupsID
    Specifies the IDs of groups for which expiration settings are to be applied. This parameter is used when ExpirationEnabled is set to 'Selected'.

    .EXAMPLE
    $Headers = @{Authorization = "Bearer your_token"}
    Set-O365AzureGroupExpiration -Headers $Headers -GroupLifeTime 365 -ExpirationEnabled 'Selected' -AdminNotificationEmails 'admin@example.com' -ExpirationGroups @('Group1', 'Group2')

    This example sets the group expiration for 'Group1' and 'Group2' with a lifetime of 365 days, where only selected groups are managed, and notifications are sent to 'admin@example.com'.

    .LINK
    https://main.iam.ad.ext.azure.com/api/Directories/LcmSettings
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[int]] $GroupLifeTime,
        [string][ValidateSet('None', 'Selected', 'All')] $ExpirationEnabled,
        [string] $AdminNotificationEmails,
        [Array] $ExpirationGroups,
        [Array] $ExpirationGroupsID
    )


    $Uri = 'https://main.iam.ad.ext.azure.com/api/Directories/LcmSettings'

    $CurrentSettings = Get-O365AzureGroupExpiration -Headers $Headers -NoTranslation

    if ($null -ne $GroupLifeTime) {
        # if group lifetime is defined we need to build 2 values
        if ($GroupLifeTime -eq 180) {
            $expiresAfterInDays = 0
            $groupLifetimeCustomValueInDays = 0
        } elseif ($GroupLifeTime -eq 365) {
            $expiresAfterInDays = 1
            $groupLifetimeCustomValueInDays = 0
        } else {
            $expiresAfterInDays = 2
            $groupLifetimeCustomValueInDays = $GroupLifeTime
        }
    } else {
        # if it's not defined we need to get current values
        $expiresAfterInDays = $CurrentSettings.expiresAfterInDays
        $groupLifetimeCustomValueInDays = $CurrentSettings.groupLifetimeCustomValueInDays
    }
    if ($ExpirationEnabled -eq 'None') {
        $ManagedGroupTypes = 2
    } elseif ($ExpirationEnabled -eq 'Selected') {
        $ManagedGroupTypes = 1
    } elseif ($ExpirationEnabled -eq 'All') {
        $ManagedGroupTypes = 0
    } else {
        $ManagedGroupTypes = $CurrentSettings.managedGroupTypes
    }
    if (-not $AdminNotificationEmails) {
        $AdminNotificationEmails = $CurrentSettings.adminNotificationEmails
    }

    if ($ExpirationGroups) {
        [Array] $GroupsID = foreach ($Ex in $ExpirationGroups) {
            $GroupFound = Get-O365Group -DisplayName $Ex -Headers $Headers
            if ($GroupFound.Id) {
                $GroupFound.Id
            }
        }
        if ($GroupsID.Count -gt 0) {
            $groupIdsToMonitorExpirations = if ($GroupsID.Count -in 0, 1) {
                , @($GroupsID)
            } else {
                $GroupsID
            }
        } else {
            Write-Warning -Message "Set-O365AzureGroupExpiration - Couldn't find any groups provided in ExpirationGroups. Skipping"
            return
        }
    } elseif ($ExpirationGroupsID) {
        $groupIdsToMonitorExpirations = if ($ExpirationGroupsID.Count -in 0, 1) {
            , @($ExpirationGroupsID)
        } else {
            $ExpirationGroupsID
        }

    } else {
        $groupIdsToMonitorExpirations = if ($CurrentSettings.groupIdsToMonitorExpirations.count -in 0, 1) {
            , @($CurrentSettings.groupIdsToMonitorExpirations)
        } else {
            $CurrentSettings.groupIdsToMonitorExpirations
        }
    }

    $Body = [ordered] @{
        expiresAfterInDays             = $expiresAfterInDays
        groupLifetimeCustomValueInDays = $groupLifetimeCustomValueInDays
        managedGroupTypesEnum          = $CurrentSettings.managedGroupTypesEnum
        managedGroupTypes              = $ManagedGroupTypes
        adminNotificationEmails        = $AdminNotificationEmails
        groupIdsToMonitorExpirations   = $groupIdsToMonitorExpirations
        policyIdentifier               = $CurrentSettings.policyIdentifier
    }

    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body

}
