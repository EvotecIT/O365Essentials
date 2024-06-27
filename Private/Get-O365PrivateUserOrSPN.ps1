function Get-O365PrivateUserOrSPN {
    <#
    .SYNOPSIS
    Retrieves an Office 365 user or service principal by their principal ID.

    .DESCRIPTION
    This function attempts to retrieve an Office 365 user or service principal using the provided principal ID. 
    It first tries to find a user with the given ID. If no user is found, it then tries to find a service principal with the same ID.
    If neither a user nor a service principal is found, it outputs any warnings encountered during the process.

    .PARAMETER PrincipalID
    The ID of the principal (user or service principal) to retrieve.

    .EXAMPLE
    $principal = Get-O365PrivateUserOrSPN -PrincipalID "user@example.com"
    This example retrieves the Office 365 user or service principal with the ID "user@example.com".

    .NOTES
    This function is useful for identifying whether a given principal ID corresponds to a user or a service principal in Office 365.
    #>
    [cmdletBinding()]
    param(
        [string] $PrincipalID
    )
    $OutputUser = Get-O365User -Id $PrincipalID -WarningAction SilentlyContinue -WarningVariable varWarning
    if ($OutputUser) {
        $OutputUser
    } else {
        $OutputService = Get-O365ServicePrincipal -Id $PrincipalID -WarningAction SilentlyContinue -WarningVariable +varWarning
        if ($OutputService) {
            $OutputService
        }
    }
    if (-not $OutputService -and -not $OutputUser) {
        foreach ($Warning in $VarWarning) {
            Write-Warning -Message $Warning
        }
    }
}
