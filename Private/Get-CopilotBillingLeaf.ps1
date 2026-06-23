function Get-CopilotBillingLeaf {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Uri,
        [System.Collections.IDictionary] $AdditionalLeafHeaders = $AdditionalHeaders
    )

    $Splat = @{
        Uri               = $Uri
        Headers           = $RequestHeaders
        Method            = 'GET'
        AdditionalHeaders = $AdditionalLeafHeaders
    }
    if ($HasPortalSessionContext -and $Uri -like 'https://admin.cloud.microsoft/*') {
        $Splat['UsePortalSession'] = $true
    }
    $Splat['QuietOnError'] = $true

    Invoke-O365Admin @Splat
}
