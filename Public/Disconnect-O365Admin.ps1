function Disconnect-O365Admin {
    [CmdletBinding()]
    param(

    )
    # quick and dirty removal of cached data that should force disconnection
    $Script:AuthorizationO365Cache = $null
}