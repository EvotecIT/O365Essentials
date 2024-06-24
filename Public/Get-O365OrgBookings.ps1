function Get-O365OrgBookings {
    <#
        .SYNOPSIS
        Retrieves the Bookings settings for the organization.
        .DESCRIPTION
        This function queries the Microsoft Graph API to retrieve the Bookings settings for the organization.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365OrgBookings -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/bookings"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
