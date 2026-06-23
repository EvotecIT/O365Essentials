function Get-CopilotConnectorLeaf {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Uri,
        [System.Collections.IDictionary] $AdditionalLeafHeaders = $AdditionalHeaders
    )

    $Splat = @{
        Uri               = $Uri
        Headers           = $Headers
        Method            = 'GET'
        AdditionalHeaders = $AdditionalLeafHeaders
    }
    if ($HasPortalSessionContext -and $Uri -like 'https://admin.cloud.microsoft/*') {
        $Splat['UsePortalSession'] = $true
    }
    $Splat['QuietOnError'] = $true
    Invoke-O365Admin @Splat
}
