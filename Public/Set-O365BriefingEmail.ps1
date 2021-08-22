function Set-O365BriefingEmail {
    <#
    .SYNOPSIS
    Let people in your organization receive Briefing Email

    .DESCRIPTION
    Let people in your organization receive Briefing Email

    .PARAMETER Headers
    Parameter description

    .PARAMETER SubscribeByDefault
    Subscribes or unsubscribes people in your organization to receive Briefing Email

    .EXAMPLE
    An example

    .NOTES
    Users will receive ‎Briefing‎ email by default, but can unsubscribe at any time from their ‎Briefing‎ email or ‎Briefing‎ settings page. Email is only sent to users if their ‎Office 365‎ language is English or Spanish.

    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        #[bool] $MailEnable,
        [bool] $SubscribeByDefault
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/briefingemail"

    $Body = @{
        value = @{
            IsSubscribedByDefault = $SubscribeByDefault
        }
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}