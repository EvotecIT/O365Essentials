function Set-O365Scripts {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter()][string][ValidateSet('Disabled', 'Everyone', 'SpecificGroup')] $LetUsersAutomateTheirTasks,
        [Parameter()][string] $LetUsersAutomateTheirTasksGroup,
        [Parameter()][string] $LetUsersAutomateTheirTasksGroupID,
        [Parameter()][string][ValidateSet('Disabled', 'Everyone', 'SpecificGroup')] $LetUsersShareTheirScripts,
        [Parameter()][string] $LetUsersShareTheirScriptsGroup,
        [Parameter()][string] $LetUsersShareTheirScriptsGroupID,
        [Parameter()][string][ValidateSet('Disabled', 'Everyone', 'SpecificGroup')] $LetUsersRunScriptPowerAutomate,
        [Parameter()][string] $LetUsersRunScriptPowerAutomateGroup,
        [Parameter()][string] $LetUsersRunScriptPowerAutomateGroupID
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officescripts"

    $Body = [ordered] @{}
    if ($LetUsersAutomateTheirTasks -eq 'Disabled') {
        # if the user wants to disable the LetUsersAutomateTheirTasks, then we need to disable all other options as well
        $Body.EnabledOption = 0
        $Body.ShareOption = 0
        $Body.UnattendedOption = 0
    } else {
        if ($LetUsersAutomateTheirTasks -or $LetUsersAutomateTheirTasksGroup -or $LetUsersAutomateTheirTasksGroupID) {
            # We check for the presence of option, but also if the user just provided a group name or ID we then assume the user wants specific group
            if ($LetUsersAutomateTheirTasks -eq 'SpecificGroup' -or $LetUsersAutomateTheirTasksGroup -or $LetUsersAutomateTheirTasksGroupID) {
                if ($LetUsersAutomateTheirTasksGroup) {
                    # we find the id of the group from the name
                    $Group = Get-O365Group -DisplayName $LetUsersAutomateTheirTasksGroup -Headers $Headers
                    if ($Group.Id) {
                        $Body.EnabledOption = 2
                        $Body.EnabledGroup = $Group.Id
                    } else {
                        Write-Warning -Message "Set-O365Scripts - LetUsersAutomateTheirTasksGroup couldn't be translated to ID. Skipping."
                        return
                    }
                } elseif ($LetUsersAutomateTheirTasksGroupID) {
                    # we use direct ID
                    $Body.EnabledOption = 2
                    $Body.EnabledGroup = $LetUsersAutomateTheirTasksGroupID
                } else {
                    Write-Warning -Message "Set-O365Scripts - LetUsersAutomateTheirTasksGroup/LetUsersAutomateTheirTasksGroupID not provided. Please provide group."
                    return
                }
            } elseif ($LetUsersAutomateTheirTasks -eq 'Everyone') {
                $Body.EnabledOption = 1
            } elseif ($LetUsersAutomateTheirTasks -eq 'Disabled') {
                $Body.EnabledOption = 0
            }
        }
        if ($LetUsersShareTheirScripts -or $LetUsersShareTheirScriptsGroup -or $LetUsersShareTheirScriptsGroupID) {
            # We check for the presence of option, but also if the user just provided a group name or ID we then assume the user wants specific group
            if ($LetUsersShareTheirScripts -eq 'SpecificGroup' -or $LetUsersShareTheirScriptsGroup -or $LetUsersShareTheirScriptsGroupID) {
                if ($LetUsersShareTheirScriptsGroup) {
                    # we find the id of the group from the name
                    $Group = Get-O365Group -DisplayName $LetUsersShareTheirScriptsGroup -Headers $Headers
                    if ($Group.Id) {
                        $Body.ShareOption = 2
                        $Body.ShareGroup = $Group.Id
                    } else {
                        Write-Warning -Message "Set-O365Scripts - LetUsersAutomateTheirTasksGroup couldn't be translated to ID. Skipping."
                        return
                    }
                } elseif ($LetUsersShareTheirScriptsGroupID) {
                    # we use direct ID
                    $Body.ShareOption = 2
                    $Body.ShareGroup = $LetUsersShareTheirScriptsGroupID
                } else {
                    Write-Warning -Message "Set-O365Scripts - LetUsersShareTheirScriptsGroup/LetUsersShareTheirScriptsGroupID not provided. Please provide group."
                    return
                }
            } elseif ($LetUsersShareTheirScripts -eq 'Everyone') {
                $Body.ShareOption = 1
            } elseif ($LetUsersShareTheirScripts -eq 'Disabled') {
                $Body.ShareOption = 0
            }
        }
        if ($LetUsersRunScriptPowerAutomate -or $LetUsersRunScriptPowerAutomateGroup -or $LetUsersRunScriptPowerAutomateGroupID) {
            # We check for the presence of option, but also if the user just provided a group name or ID we then assume the user wants specific group
            if ($LetUsersRunScriptPowerAutomate -eq 'SpecificGroup' -or $LetUsersRunScriptPowerAutomateGroup -or $LetUsersRunScriptPowerAutomateGroupID) {
                if ($LetUsersRunScriptPowerAutomateGroup) {
                    # we find the id of the group from the name
                    $Group = Get-O365Group -DisplayName $LetUsersRunScriptPowerAutomateGroup -Headers $Headers
                    if ($Group.Id) {
                        $Body.UnattendedOption = 2
                        $Body.UnattendedGroup = $Group.Id
                    } else {
                        Write-Warning -Message "Set-O365Scripts - LetUsersRunScriptPowerAutomateGroup couldn't be translated to ID. Skipping."
                        return
                    }
                } elseif ($LetUsersRunScriptPowerAutomateGroupID) {
                    # we use direct ID
                    $Body.UnattendedOption = 2
                    $Body.UnattendedGroup = $LetUsersRunScriptPowerAutomateGroupID
                } else {
                    Write-Warning -Message "Set-O365Scripts - LetUsersShareTheirScriptsGroup/LetUsersRunScriptPowerAutomateGroupID not provided. Please provide group."
                    return
                }
            } elseif ($LetUsersRunScriptPowerAutomateGroup -eq 'Everyone') {
                $Body.UnattendedOption = 1
            } elseif ($LetUsersRunScriptPowerAutomateGroup -eq 'Disabled') {
                $Body.UnattendedOption = 0
            }
        }
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}