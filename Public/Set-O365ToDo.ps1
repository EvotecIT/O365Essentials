function Set-O365Todo {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $ExternalJoinEnabled,
        [nullable[bool]] $PushNotificationEnabled,
        [nullable[bool]] $ExternalShareEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/todo"

    $CurrentSettings = Get-O365ToDo
    if ($CurrentSettings) {
        $Body = @{
            IsExternalJoinEnabled     = $CurrentSettings.IsExternalJoinEnabled
            IsPushNotificationEnabled = $CurrentSettings.IsPushNotificationEnabled
            IsExternalShareEnabled    = $CurrentSettings.IsExternalShareEnabled
        }
        if ($null -ne $ExternalJoinEnabled) {
            $Body.IsExternalJoinEnabled = $ExternalJoinEnabled
        }
        if ($null -ne $PushNotificationEnabled) {
            $Body.IsPushNotificationEnabled = $PushNotificationEnabled
        }
        if ($null -ne $ExternalShareEnabled) {
            $Body.IsExternalShareEnabled = $ExternalShareEnabled
        }
        Remove-EmptyValue -Hashtable $Body
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}