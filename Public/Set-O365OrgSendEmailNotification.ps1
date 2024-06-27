function Set-O365OrgSendEmailNotification {
    <#
    .SYNOPSIS
    Sets the email notification settings for an Office 365 tenant.

    .DESCRIPTION
    This function allows you to set the email notification settings for an Office 365 tenant.
    You can specify the 'SendFromAddress' and whether to remove the current settings.

    .PARAMETER Headers
    The headers for the request, typically including the authorization token. This is optional.

    .PARAMETER SendFromAddress
    The email address that the notifications will be sent from.

    .PARAMETER Remove
    A switch parameter. If specified, the current settings will be removed.

    .EXAMPLE
    Set-O365OrgSendEmailNotification -SendFromAddress "admin@mydomain.com"
    This example sets the 'SendFromAddress' to 'admin@mydomain.com'.

    .EXAMPLE
    Set-O365OrgSendEmailNotification -Remove
    This example removes the current settings.

    .NOTES
    More information can be found at: https://admin.microsoft.com/Adminportal/Home?#/Settings/OrganizationProfile/:/Settings/L1/SendFromAddressSettings
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Email')]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory, ParameterSetName = 'Email')][string] $SendFromAddress,
        [parameter(ParameterSetName = 'Remove')]
        [switch] $Remove
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/sendfromaddress"
    if ($Remove) {
        $Body = @{
            ServiceEnabled        = $false
            TenantSendFromAddress = ""
        }
    } else {
        $Body = @{
            ServiceEnabled        = if ($SendFromAddress) { $true } else { $false }
            TenantSendFromAddress = $SendFromAddress
        }
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    if ($Output) {
        $Output
    }
}