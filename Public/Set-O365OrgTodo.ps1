function Set-O365OrgTodo {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $ExternalJoinEnabled,
        [nullable[bool]] $PushNotificationEnabled,
        [nullable[bool]] $ExternalShareEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/todo"

    $CurrentSettings = Get-O365ToDo -Headers $Headers
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
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}