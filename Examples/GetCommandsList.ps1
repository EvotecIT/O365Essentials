Import-Module O365Essentials -Force

$Commands = Get-Command -Module O365Essentials
$CommandsOnly = $Commands | Where-Object { $_.CommandType -eq 'Function' }

$List = [ordered] @{}
foreach ($Command in $CommandsOnly) {
    if ($Command.Name.StartsWith('Get')) {
        $CommandType = 'Get'
    } elseif ($Command.Name.StartsWith('Set')) {
        $CommandType = 'Set'
    } else {
        $CommandType = 'Other'
    }
    if ($CommandType -ne 'Other') {
        $Name = $Command.Name.Replace("Get-", '').Replace("Set-", '')
        if (-not $List[$Name]) {
            $List[$Name] = [PSCustomObject] @{
                #Get = $CommandType -eq 'Get'
                Get = if ($CommandType -eq 'Get') { $Command.Name } else { '' }
                #Set = $CommandType -eq 'Set'
                Set = if ($CommandType -eq 'Set') { $Command.Name } else { '' }
            }
        } else {
            $List[$Name].$CommandType = $Command.Name
        }
    }
}

$List.Values | Format-Table