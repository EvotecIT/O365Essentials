function Set-O365OrgWhiteboard {
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
