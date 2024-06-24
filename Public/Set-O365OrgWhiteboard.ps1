function Set-O365OrgWhiteboard {
    <#
    .SYNOPSIS
    Configures settings for the Office 365 Whiteboard application.

    .DESCRIPTION
    This function updates the configuration settings for the Office 365 Whiteboard application. It allows enabling or disabling the Whiteboard, setting diagnostic data sharing preferences, and configuring related features like connected experiences, board sharing, and OneDrive storage.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER WhiteboardEnabled
    Specifies whether the Whiteboard is enabled or disabled.

    .PARAMETER DiagnosticData
    Specifies the level of diagnostic data allowed. Valid values are 'Neither', 'Required', 'Optional'.

    .PARAMETER OptionalConnectedExperiences
    Specifies whether optional connected experiences are enabled.

    .PARAMETER BoardSharingEnabled
    Specifies whether board sharing is enabled.

    .PARAMETER OneDriveStorageEnabled
    Specifies whether OneDrive storage is enabled for Whiteboard.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgWhiteboard -Headers $headers -WhiteboardEnabled $true -DiagnosticData 'Optional' -OptionalConnectedExperiences $true -BoardSharingEnabled $true -OneDriveStorageEnabled $true

    This example enables the Whiteboard with optional diagnostic data, connected experiences, board sharing, and OneDrive storage.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $WhiteboardEnabled,
        [ValidateSet('Neither', 'Required', 'Optional')]$DiagnosticData,
        [nullable[bool]] $OptionalConnectedExperiences,
        [nullable[bool]] $BoardSharingEnabled,
        [nullable[bool]] $OneDriveStorageEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/whiteboard"

    $CurrentSettings = Get-O365OrgWhiteboard -Headers $Headers -NoTranslation

    $Body = [ordered] @{
        IsEnabled                   = $CurrentSettings.IsEnabled                   # : True
        IsClaimEnabled              = $CurrentSettings.IsClaimEnabled              #: True
        IsSharePointDefault         = $CurrentSettings.IsSharePointDefault         #: False
        # This always seems to be 0, but i'll let it read it from Get-O365OrgWhiteboard
        NonTenantAccess             = $CurrentSettings.NonTenantAccess             #: 0
        TelemetryPolicy             = $CurrentSettings.TelemetryPolicy             #: 2
        AreConnectedServicesEnabled = $CurrentSettings.AreConnectedServicesEnabled #: True
    }
    if ($null -ne $WhiteboardEnabled) {
        $Body.IsEnabled = $WhiteboardEnabled
    }
    if ($DiagnosticData) {
        $ReverseTranslateTelemetry = @{
            'Neither'  = 0
            'Required' = 1
            'Optional' = 2
        }
        $Body.TelemetryPolicy = $ReverseTranslateTelemetry[$DiagnosticData]
    }
    if ($null -ne $OptionalConnectedExperiences) {
        $Body.AreConnectedServicesEnabled = $OptionalConnectedExperiences
    }
    if ($null -ne $BoardSharingEnabled) {
        $Body.IsClaimEnabled = $BoardSharingEnabled
    }
    if ($null -ne $OneDriveStorageEnabled) {
        $Body.IsSharePointDefault = $OneDriveStorageEnabled
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
