function Get-O365PrivateUserOrSPN {
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