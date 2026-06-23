function Get-O365EssentialsConfigPath {
    $base = [Environment]::GetFolderPath('ApplicationData')
    if (-not $base) {
        $base = $HOME
    }
    Join-Path $base 'O365Essentials/config.json'
}
