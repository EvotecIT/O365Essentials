function Get-O365OrgVivaLearning {
    <#
    .SYNOPSIS
    Retrieves organization Viva Learning settings.

    .DESCRIPTION
    This function retrieves organization Viva Learning settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/learning'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}