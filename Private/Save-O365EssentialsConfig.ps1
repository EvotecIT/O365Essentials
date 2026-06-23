function Save-O365EssentialsConfig {
    param([Parameter(Mandatory)][psobject] $Config)

    $path = Get-O365EssentialsConfigPath
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $Config | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
}
