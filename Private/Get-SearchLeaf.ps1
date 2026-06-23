function Get-SearchLeaf {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Uri,
        [ValidateSet('GET', 'POST')][string] $Method = 'GET',
        [object] $Body,
        [switch] $QuietOnError
    )

    $Splat = @{
        Uri               = $Uri
        Headers           = $Headers
        Method            = $Method
        AdditionalHeaders = $AdditionalHeaders
    }
    if ($Method -eq 'POST') {
        $Splat['ContentType'] = 'application/json'
    }
    if ($HasPortalSessionContext) {
        $Splat['UsePortalSession'] = $true
    }
    if ($PSBoundParameters.ContainsKey('Body')) {
        $Splat['Body'] = $Body
    }
    if ($QuietOnError) {
        $Splat['QuietOnError'] = $true
    }
    else {
        $Splat['QuietOnError'] = $true
    }
    Invoke-O365Admin @Splat
}
