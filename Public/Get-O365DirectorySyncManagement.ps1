function Get-O365DirectorySyncManagement {
    <#
    .SYNOPSIS
    Retrieves directory synchronization management details from Office 365.

    .DESCRIPTION
    This function retrieves directory synchronization management details from Office 365 using the specified API endpoint and headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/DirsyncManagement/manage"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
