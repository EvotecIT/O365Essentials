function Get-O365EssentialsConfig {
    $path = Get-O365EssentialsConfigPath
    if (Test-Path $path) {
        try {
            return Get-Content $path -Raw | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
        }
    }
    [pscustomobject]@{ Substrate = $null }
}
