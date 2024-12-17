function Get-O365GroupAdministrativeUnit {
    <#
    .SYNOPSIS
    Retrieves the administrative unit of an Office 365 group.

    .DESCRIPTION
    This function retrieves the administrative unit of an Office 365 group based on the provided GroupID or GroupDisplayName.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER GroupID
    The ID of the group to query. Default value is '75233998-a950-41de-97d0-6c259d0580a7'.

    .PARAMETER GroupDisplayName
    The display name of the group to query.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter()][string] $GroupID = '75233998-a950-41de-97d0-6c259d0580a7'
    )

    if ($GroupID) {
        $Group = $GroupID
    } elseif ($GroupDisplayName) {
        $Group = $GroupDisplayName
    }
    #$Uri = "https://graph.microsoft.com/beta/groups/$Group/memberOf/microsoft.graph.administrativeUnit"
    $Uri = "https://graph.microsoft.com/v1.0/groups/$Group/memberOf/microsoft.graph.administrativeUnit"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
