function Get-O365OrgBriefingEmail {
    <#
        .SYNOPSIS
        Retrieves the status of Briefing emails for the organization.
        .DESCRIPTION
        This function queries the Microsoft Graph API to retrieve the status of Briefing emails for the organization.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365OrgBriefingEmail -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/services/apps/briefingemail"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            IsMailEnabled         = $Output.IsMailEnabled
            IsSubscribedByDefault = $Output.IsSubscribedByDefault
        }
    }
}
