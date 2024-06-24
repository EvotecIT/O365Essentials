function Get-O365AzureExternalCollaborationSettings {
    <#
        .SYNOPSIS
        Retrieves Azure external collaboration settings based on the provided headers.
        .DESCRIPTION
        This function retrieves Azure external collaboration settings from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $ReverseGuestRole = @{
        'a0b1b346-4d3e-4e8b-98f8-753987be4970' = 'User'
        '10dae51f-b6af-4016-8d66-8c2a99b929b3' = 'GuestUser'
        '2af84b1e-32c8-42b7-82bc-daa82404023b' = 'RestrictedUser'
    }

    $Uri = 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            #id                                        = $Output.id                                        # : authorizationPolicy
            allowInvitesFrom                          = $Output.allowInvitesFrom                          # : adminsAndGuestInviters
            allowedToSignUpEmailBasedSubscriptions    = $Output.allowedToSignUpEmailBasedSubscriptions    # : True
            allowedToUseSSPR                          = $Output.allowedToUseSSPR                          # : True
            allowEmailVerifiedUsersToJoinOrganization = $Output.allowEmailVerifiedUsersToJoinOrganization # : False
            blockMsolPowerShell                       = $Output.blockMsolPowerShell                       # : False
            displayName                               = $Output.displayName                               # : Authorization Policy
            description                               = $Output.description                               # : Used to manage authorization related settings across the company.
            guestUserRoleId                           = $ReverseGuestRole[$Output.guestUserRoleId]                           # : a0b1b346-4d3e-4e8b-98f8-753987be4970
            defaultUserRolePermissions                = $Output.defaultUserRolePermissions                # :
        }
    }
}

<#
$o = Invoke-WebRequest -Uri "https://graph.microsoft.com/beta/policies/authenticationFlowsPolicy" -Headers @{
    "x-ms-client-session-id" = "a2f6c5f9b1b8450dbb0116f95ffbe9b2"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer .
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    #"Referer"=""
    "x-ms-client-request-id" = "d4bc027d-339c-46c2-ba96-c07f53fc5002"
    "User-Agent"             = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84"
}
$o.content

$p = Invoke-WebRequest -Uri "https://graph.microsoft.com/beta/policies/authorizationPolicy" -Headers @{
    "x-ms-client-session-id" = "a2f6c5f9b1b8450dbb0116f95ffbe9b2"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer ..
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    #"Referer"                = ""
    "x-ms-client-request-id" = "d4bc027d-339c-46c2-ba96-c07f53fc5001"
    "User-Agent"             = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84"
}
$p.COntent

$g = Invoke-WebRequest -Uri "https://main.iam.ad.ext.azure.com/api/B2B/b2bPolicy" `
    -Headers @{
    "x-ms-client-session-id" = "02ca6867073543de9a89b767ad581135"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer "
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    #"Referer"                = ""
    "User-Agent"             = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84"
    "x-ms-client-request-id" = "cf957d13-fc12-415d-a86a-1d74507d9003"
} `
    -ContentType "application/json"
$g.content
#>
