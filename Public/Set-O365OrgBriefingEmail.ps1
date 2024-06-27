function Set-O365OrgBriefingEmail {
    <#
    .SYNOPSIS
    Configures the Briefing Email feature for an Office 365 organization.

    .DESCRIPTION
    Let people in your organization receive Briefing Email

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER SubscribeByDefault
    Specifies whether people in your organization should be subscribed to receive Briefing Email by default.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgBriefingEmail -Headers $headers -SubscribeByDefault $true

    This example sets the Briefing Email feature to be subscribed by default for the Office 365 organization.

    .NOTES
    Users will receive Briefing email by default, but can unsubscribe at any time from their Briefing email or Briefing settings page. Email is only sent to users if their Office 365 language is English or Spanish.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        #[bool] $MailEnable,
        [bool] $SubscribeByDefault
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/briefingemail"

    $Body = @{
        value = @{
            IsSubscribedByDefault = $SubscribeByDefault
        }
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
