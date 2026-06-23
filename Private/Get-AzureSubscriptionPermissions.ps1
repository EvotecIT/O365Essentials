function Get-AzureSubscriptionPermissions {
    $AzureSubscriptions = @(Get-O365OrgBackup -Headers $Headers -Name AzureSubscriptions)
    if ($AzureSubscriptions.Count -eq 1 -and (Test-O365UnavailableResult -InputObject $AzureSubscriptions[0])) {
        return $AzureSubscriptions[0]
    }

    foreach ($Subscription in $AzureSubscriptions) {
        [PSCustomObject] @{
            SubscriptionId = $Subscription.subscriptionId
            DisplayName    = $Subscription.displayName
            Permissions    = Invoke-O365SectionSafeResult -Section Backup -ResultName ("AzureSubscriptionPermissions:{0}" -f $Subscription.subscriptionId) -ScriptBlock { Get-BackupLeaf -Uri ("https://admin.microsoft.com/admin/api/syntexbilling/azureSubscriptions/{0}/permissions" -f $Subscription.subscriptionId) }
        }
    }
}
