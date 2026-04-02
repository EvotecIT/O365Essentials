$Configuration = Connect-O365Admin

$Report = Get-O365InternalApiValidationReport -Headers $Configuration
$Report.Summary
$Report.PrioritizedFindings | Format-Table Area, Component, Name, Priority, SuggestedCommand -AutoSize
