function Get-O365ExternalCollaborationSettings {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    #$Uri = 'https://graph.microsoft.com/beta/policies/authorizationPolicy'
    $Uri = 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy'
    Invoke-O365Admin -Uri $Uri -Headers $Headers
}