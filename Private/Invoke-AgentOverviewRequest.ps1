function Invoke-AgentOverviewRequest {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Uri,
        [string] $UsageOrigin,
        [switch] $QuietOnError
    )

    $LeafHeaders = [ordered] @{}
    foreach ($Key in $AdditionalHeaders.Keys) {
        $LeafHeaders[$Key] = $AdditionalHeaders[$Key]
    }
    $LeafHeaders['x-adminapp-request'] = '/agents/overview'

    if ($Uri -like 'https://admin.cloud.microsoft/fd/addins/api/*') {
        $LeafHeaders['x-admin-portal-flight'] = 'UDShowTeamsAppInAvailableList,UDAddInToMosUpdateEnabled,UDAIAdminEnabled'
        if (-not [string]::IsNullOrWhiteSpace($UsageOrigin)) {
            $LeafHeaders['x-usage-origin'] = $UsageOrigin
        }
    }

    $Splat = @{
        Uri               = $Uri
        Headers           = $Headers
        Method            = 'GET'
        AdditionalHeaders = $LeafHeaders
        UsePortalSession  = $UsePortalSession
    }
    if ($QuietOnError) {
        $Splat['QuietOnError'] = $true
    }
    Invoke-O365Admin @Splat
}
