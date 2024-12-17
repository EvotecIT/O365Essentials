function Disconnect-O365Admin {
    <#
    .SYNOPSIS
    Disconnects from Office 365 as an administrator by clearing cached authorization data.

    .DESCRIPTION
    This function disconnects the current PowerShell session from Office 365 by removing cached authorization data. 
    It is a quick and dirty method to force disconnection from Office 365 services.

    .EXAMPLE
    Disconnect-O365Admin
    This example disconnects the current PowerShell session from Office 365 by clearing cached authorization data.

    .NOTES
    This function is useful for administrators who need to explicitly disconnect from Office 365 services, ensuring a clean session state.
    #>
    [CmdletBinding()]
    param(

    )
    # quick and dirty removal of cached data that should force disconnection
    $Script:AuthorizationO365Cache = $null
}