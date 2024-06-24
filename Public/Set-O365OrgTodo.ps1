function Set-O365OrgTodo {
    <#
        .SYNOPSIS
        Configures settings for Microsoft To-Do in Office 365.
        .DESCRIPTION
        This function updates the configuration settings for Microsoft To-Do in Office 365. It allows enabling or disabling external join, push notifications, and external sharing.
        .PARAMETER Headers
        Specifies the headers for the API request. Typically includes authorization tokens.
        .PARAMETER ExternalJoinEnabled
        Specifies whether external join is enabled or disabled.
        .PARAMETER PushNotificationEnabled
        Specifies whether push notifications are enabled or disabled.
        .PARAMETER ExternalShareEnabled
        Specifies whether external sharing is enabled or disabled.
        .EXAMPLE
        $headers = @{Authorization = "Bearer your_token"}
        Set-O365OrgTodo -Headers $headers -ExternalJoinEnabled $true -PushNotificationEnabled $false -ExternalShareEnabled $true

        This example enables external join, disables push notifications, and enables external sharing for Microsoft To-Do.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $ExternalJoinEnabled,
        [nullable[bool]] $PushNotificationEnabled,
        [nullable[bool]] $ExternalShareEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/todo"

    $CurrentSettings = Get-O365OrgToDo -Headers $Headers
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
