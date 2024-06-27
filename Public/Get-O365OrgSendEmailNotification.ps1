function Get-O365OrgSendEmailNotification {
    <#
    .SYNOPSIS
    Retrieves organization email notification settings.

    .DESCRIPTION
    This function retrieves organization email notification settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request. This parameter is required to authenticate the request and provide necessary details for the API call.

    .EXAMPLE
    Get-O365OrgSendEmailNotification -Headers $headers

    .NOTES
    This function retrieves organization email notification settings from the specified URI. It is designed to provide a comprehensive overview of the organization's email notification settings.
    #>
    [CmdletBinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/sendfromaddress"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}