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

    $RequiredGroups = @(
        foreach ($Scope in @($RequiredScope)) {
            foreach ($Part in ($Scope -split '\s+')) {
                if (-not [string]::IsNullOrWhiteSpace($Part) -and $Part -notin 'offline_access', 'openid', 'profile', 'email') {
                    , @($Part.Trim() -split '\|' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() })
                }
            }
        }
    )

    if ($RequiredGroups.Count -eq 0) {
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

    foreach ($RequiredGroup in $RequiredGroups) {
        $Matched = $false
        foreach ($Scope in @($RequiredGroup)) {
            if ($Granted.Contains($Scope)) {
                $Matched = $true
                break
            }
        }
        if (-not $Matched) {
            return $false
        }
    }

    $true
}
