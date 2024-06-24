function Get-O365OrgCommunicationToUsers {
    <#
        .SYNOPSIS
        Retrieves information about end user communications settings.
        .DESCRIPTION
        This function retrieves information about end user communications settings from the specified URI.
        .PARAMETER Headers
        Specifies the headers containing the authorization information.
        .EXAMPLE
        Get-O365OrgCommunicationToUsers -Headers $Headers
        .NOTES
        General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/EndUserCommunications'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
