function Get-O365CopilotPin {
    <#
    .SYNOPSIS
    Retrieves the Copilot PIN settings for the organization.

    .DESCRIPTION
    The Get-O365CopilotPin function sends a GET request to the Microsoft 365 admin API to retrieve the Copilot PIN settings for the organization.

    .PARAMETER Headers
    The authorization headers required to authenticate the API request.

    .EXAMPLE
    Get-O365CopilotPin -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/company/copilotpolicy/pin"
    $OutputSettings = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET
    $OutputSettings
}