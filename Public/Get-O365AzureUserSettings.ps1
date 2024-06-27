function Get-O365AzureUserSettings {
    <#
    .SYNOPSIS
    Retrieves Azure user settings from the specified URI.

    .DESCRIPTION
    This function retrieves Azure user settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Specifies the headers required for the API request.

    .EXAMPLE
    Get-O365AzureUserSettings -Headers $Headers
    An example of how to retrieve Azure user settings using specified headers.

    .NOTES
    Based on: https://main.iam.ad.ext.azure.com/api/Directories/Properties
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )

    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories/Properties"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            [PSCustomObject] @{
                objectId                                  = $Output.objectId                                  #: ceb371f6 - 8745 - 4876-a040 - 69f2d10a9d1a
                displayName                               = $Output.displayName                               #: Evotec
                usersCanRegisterApps                      = $Output.usersCanRegisterApps                      #: True
                isAnyAccessPanelPreviewFeaturesAvailable  = $Output.isAnyAccessPanelPreviewFeaturesAvailable  #: False
                showMyGroupsFeature                       = $Output.showMyGroupsFeature                       #: False
                myGroupsFeatureValue                      = $Output.myGroupsFeatureValue                      #:
                myGroupsGroupId                           = $Output.myGroupsGroupId                           #:
                myGroupsGroupName                         = $Output.myGroupsGroupName                         #:
                showMyAppsFeature                         = $Output.showMyAppsFeature                         #: False
                myAppsFeatureValue                        = $Output.myAppsFeatureValue                        #:
                myAppsGroupId                             = $Output.myAppsGroupId                             #:
                myAppsGroupName                           = $Output.myAppsGroupName                           #:
                showUserActivityReportsFeature            = $Output.showUserActivityReportsFeature            #: False
                userActivityReportsFeatureValue           = $Output.userActivityReportsFeatureValue           #:
                userActivityReportsGroupId                = $Output.userActivityReportsGroupId                #:
                userActivityReportsGroupName              = $Output.userActivityReportsGroupName              #:
                showRegisteredAuthMethodFeature           = $Output.showRegisteredAuthMethodFeature           #: False
                registeredAuthMethodFeatureValue          = $Output.registeredAuthMethodFeatureValue          #:
                registeredAuthMethodGroupId               = $Output.registeredAuthMethodGroupId               #:
                registeredAuthMethodGroupName             = $Output.registeredAuthMethodGroupName             #:
                usersCanAddExternalUsers                  = $Output.usersCanAddExternalUsers                  #: False
                limitedAccessCanAddExternalUsers          = $Output.limitedAccessCanAddExternalUsers          #: False
                restrictDirectoryAccess                   = $Output.restrictDirectoryAccess                   #: False
                groupsInAccessPanelEnabled                = $Output.groupsInAccessPanelEnabled                #: False
                selfServiceGroupManagementEnabled         = $Output.selfServiceGroupManagementEnabled         #: True
                securityGroupsEnabled                     = $Output.securityGroupsEnabled                     #: False
                usersCanManageSecurityGroups              = $Output.usersCanManageSecurityGroups              #:
                office365GroupsEnabled                    = $Output.office365GroupsEnabled                    #: False
                usersCanManageOfficeGroups                = $Output.usersCanManageOfficeGroups                #:
                allUsersGroupEnabled                      = $Output.allUsersGroupEnabled                      #: False
                scopingGroupIdForManagingSecurityGroups   = $Output.scopingGroupIdForManagingSecurityGroups   #:
                scopingGroupIdForManagingOfficeGroups     = $Output.scopingGroupIdForManagingOfficeGroups     #:
                scopingGroupNameForManagingSecurityGroups = $Output.scopingGroupNameForManagingSecurityGroups #:
                scopingGroupNameForManagingOfficeGroups   = $Output.scopingGroupNameForManagingOfficeGroups   #:
                objectIdForAllUserGroup                   = $Output.objectIdForAllUserGroup                   #:
                allowInvitations                          = $Output.allowInvitations                          #: False
                isB2CTenant                               = $Output.isB2CTenant                               #: False
                restrictNonAdminUsers                     = $Output.restrictNonAdminUsers                     #: False
                toEnableLinkedInUsers                     = $Output.toEnableLinkedInUsers                     #: {}
                toDisableLinkedInUsers                    = $Output.toDisableLinkedInUsers                    #: {}
                # We try to make it the same as shown in Set-O365UserSettings
                linkedInAccountConnection                 = if ($Output.enableLinkedInAppFamily -eq 4) { $true } elseif ($Output.enableLinkedInAppFamily -eq 0) { $true } else { $false }
                linkedInSelectedGroupObjectId             = $Output.linkedInSelectedGroupObjectId             #: b6cdb9c3-d660 - 4558-bcfd - 82c14a986b56
                linkedInSelectedGroupDisplayName          = $Output.linkedInSelectedGroupDisplayName          #: All Users
            }
        }
    }
}
