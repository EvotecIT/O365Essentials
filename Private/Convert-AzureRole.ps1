function Convert-AzureRole {
    [cmdletbinding()]
    param(
        [string[]] $RoleID
    )
    $Roles = [ordered] @{
        '729827e3-9c14-49f7-bb1b-9608f156bbb8' = 'Helpdesk admin'
        '62e90394-69f5-4237-9190-012177145e10' = 'Global Administrator'
    }
    foreach ($Role in $RoleID) {
        $RoleName = $Roles[$Role]
        if ($RoleName) {
            $RoleName
        } else {
            $Role
        }
    }
}