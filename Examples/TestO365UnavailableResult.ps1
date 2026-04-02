Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

$Result = Get-O365CopilotOverview -Name Security -Verbose
$Result.PSObject.Properties.Value | ForEach-Object {
    if (Test-O365UnavailableResult $_) {
        $_
    }
}
