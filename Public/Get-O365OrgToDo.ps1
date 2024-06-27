function Get-O365OrgToDo {
    <#
    .SYNOPSIS
    Retrieves organization To-Do app settings.

    .DESCRIPTION
    This function retrieves organization To-Do app settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/todo"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
