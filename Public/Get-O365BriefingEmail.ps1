function Get-O365BriefingEmail {
    <#
    .SYNOPSIS
    Gets status of Briefing emails.

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
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