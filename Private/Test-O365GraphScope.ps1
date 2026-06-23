function Test-O365GraphScope {
    <#
    .SYNOPSIS
    Checks whether granted Graph scopes satisfy a command requirement.
    #>
    [cmdletbinding()]
    param(
        [string[]] $GrantedScope,
        [string[]] $RequiredScope
    )

    $Required = @(
        foreach ($Scope in @($RequiredScope)) {
            foreach ($Part in ($Scope -split '\s+')) {
                if (-not [string]::IsNullOrWhiteSpace($Part) -and $Part -notin 'offline_access', 'openid', 'profile', 'email') {
                    $Part.Trim()
                }
            }
        }
    )

    if ($Required.Count -eq 0) {
        return $true
    }

    $Granted = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($Scope in @($GrantedScope)) {
        foreach ($Part in ($Scope -split '\s+')) {
            if (-not [string]::IsNullOrWhiteSpace($Part)) {
                [void] $Granted.Add($Part.Trim())
            }
        }
    }

    foreach ($Scope in $Required) {
        if (-not $Granted.Contains($Scope)) {
            return $false
        }
    }

    $true
}
