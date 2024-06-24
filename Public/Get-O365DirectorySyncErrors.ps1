function Get-O365DirectorySyncErrors {
    <#
        .SYNOPSIS
        Retrieves directory synchronization errors from Office 365.
        .DESCRIPTION
        This function retrieves directory synchronization errors from Office 365 using the specified API endpoint and headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365DirectorySyncErrors -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/dirsyncerrors/listdirsyncerrors"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST
    if ($Output.ObjectsWithErrorsList) {
        $Output.ObjectsWithErrorsList
    }
}
