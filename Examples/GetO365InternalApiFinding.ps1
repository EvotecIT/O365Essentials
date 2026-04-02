$Configuration = Connect-O365Admin

$Health = Get-O365InternalApiHealth -Headers $Configuration
$Health | Get-O365InternalApiFinding | Format-Table Area, Component, Name, Reason, SuggestedCommand -AutoSize
