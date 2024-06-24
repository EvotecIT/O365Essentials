function Get-O365ConsiergeAll {
    <#
    .SYNOPSIS
    Retrieves configuration information for the Concierge service in Office 365.

    .DESCRIPTION
    This function retrieves configuration information for the Concierge service in Office 365 from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365ConsiergeAll -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/api/concierge/GetConciergeConfigAll"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
