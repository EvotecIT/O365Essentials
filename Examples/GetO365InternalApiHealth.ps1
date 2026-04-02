$Configuration = Connect-O365Admin

Get-O365InternalApiHealth -Headers $Configuration | Format-Table Area, Status, ComponentCount, UnavailableCount -AutoSize

Get-O365InternalApiHealth -Headers $Configuration -Area Copilot, Agents -Mode Deep |
    Where-Object Status -ne 'Healthy' |
    Select-Object Area, Status, UnavailableNames, UnavailablePaths
