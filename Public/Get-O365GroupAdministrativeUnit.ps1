function Get-O365GroupAdministrativeUnit {
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
    $Uri = "https://graph.microsoft.com/v1.0/groups/$Group/memberOf/microsoft.graph.administrativeUnit"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}