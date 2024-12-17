function Get-O365DirectorySync {
    <#
    .SYNOPSIS
    Retrieves directory synchronization settings from Office 365.

    .DESCRIPTION
    This function retrieves directory synchronization settings from Office 365 using the specified API endpoint and headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/dirsync"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
