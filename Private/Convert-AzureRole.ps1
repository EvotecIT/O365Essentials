function Convert-AzureRole {
    <#
        .SYNOPSIS
        Converts Azure role IDs to their corresponding role names.
        .DESCRIPTION
        This function takes one or more Azure role IDs and converts them to their human-readable role names. If the -All switch is used, it returns all available role names.
        .PARAMETER RoleID
        An array of Azure role IDs to be converted to role names.
        .PARAMETER All
        A switch parameter. If specified, the function returns all role names available in the system.
        .EXAMPLE
        Convert-AzureRole -RoleID '62e90394-69f5-4237-9190-012177145e10'
        Returns 'Global Administrator'.
        .EXAMPLE
        Convert-AzureRole -All
        Returns all role names available in the system.
        .NOTES
        This function is useful for mapping role IDs to their descriptive names in scripts and reports.
    #>
    [cmdletbinding()]
    param(
        [string[]] $RoleID,
        [switch] $All
    )
    $Roles = [ordered] @{
        '62e90394-69f5-4237-9190-012177145e10' = 'Global Administrator' #     True
        '10dae51f-b6af-4016-8d66-8c2a99b929b3' = 'Guest User' #     True
        '2af84b1e-32c8-42b7-82bc-daa82404023b' = 'Restricted Guest User' #     True
        '95e79109-95c0-4d8e-aee3-d01accf2d47b' = 'Guest Inviter' #     True
        'fe930be7-5e62-47db-91af-98c3a49a38b1' = 'User Administrator' #     True
        '729827e3-9c14-49f7-bb1b-9608f156bbb8' = 'Helpdesk Administrator' #     True
        'f023fd81-a637-4b56-95fd-791ac0226033' = 'Service Support Administrator' #     True
        'b0f54661-2d74-4c50-afa3-1ec803f12efe' = 'Billing Administrator' #     True
        'a0b1b346-4d3e-4e8b-98f8-753987be4970' = 'User' #     True
        '4ba39ca4-527c-499a-b93d-d9b492c50246' = 'Partner Tier1 Support' #     True
        'e00e864a-17c5-4a4b-9c06-f5b95a8d5bd8' = 'Partner Tier2 Support' #     True
        '88d8e3e3-8f55-4a1e-953a-9b9898b8876b' = 'Directory Readers' #     True
        '9360feb5-f418-4baa-8175-e2a00bac4301' = 'Directory Writers' #     True
        '29232cdf-9323-42fd-ade2-1d097af3e4de' = 'Exchange Administrator' #     True
        'f28a1f50-f6e7-4571-818b-6a12f2af6b6c' = 'SharePoint Administrator' #     True
        '75941009-915a-4869-abe7-691bff18279e' = 'Skype for Business Administrator' #     True
        'd405c6df-0af8-4e3b-95e4-4d06e542189e' = 'Device Users' #     True
        '9f06204d-73c1-4d4c-880a-6edb90606fd8' = 'Azure AD Joined Device Local Administrator' #     True
        '9c094953-4995-41c8-84c8-3ebb9b32c93f' = 'Device Join' #     True
        'c34f683f-4d5a-4403-affd-6615e00e3a7f' = 'Workplace Device Join' #     True
        '17315797-102d-40b4-93e0-432062caca18' = 'Compliance Administrator' #     True
        'd29b2b05-8046-44ba-8758-1e26182fcf32' = 'Directory Synchronization Accounts' #     True
        '2b499bcd-da44-4968-8aec-78e1674fa64d' = 'Device Managers' #     True
        '9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3' = 'Application Administrator' #     True
        'cf1c38e5-3621-4004-a7cb-879624dced7c' = 'Application Developer' #     True
        '5d6b6bb7-de71-4623-b4af-96380a352509' = 'Security Reader' #     True
        '194ae4cb-b126-40b2-bd5b-6091b380977d' = 'Security Administrator' #     True
        'e8611ab8-c189-46e8-94e1-60213ab1f814' = 'Privileged Role Administrator' #     True
        '3a2c62db-5318-420d-8d74-23affee5d9d5' = 'Intune Administrator' #     True
        '158c047a-c907-4556-b7ef-446551a6b5f7' = 'Cloud Application Administrator' #     True
        '5c4f9dcd-47dc-4cf7-8c9a-9e4207cbfc91' = 'Customer LockBox Access Approver' #     True
        '44367163-eba1-44c3-98af-f5787879f96a' = 'Dynamics 365 Administrator' #     True
        'a9ea8996-122f-4c74-9520-8edcd192826c' = 'Power BI Administrator' #     True
        'b1be1c3e-b65d-4f19-8427-f6fa0d97feb9' = 'Conditional Access Administrator' #     True
        '4a5d8f65-41da-4de4-8968-e035b65339cf' = 'Reports Reader' #     True
        '790c1fb9-7f7d-4f88-86a1-ef1f95c05c1b' = 'Message Center Reader' #     True
        '7495fdc4-34c4-4d15-a289-98788ce399fd' = 'Azure Information Protection Administrator' #     True
        '38a96431-2bdf-4b4c-8b6e-5d3d8abac1a4' = 'Desktop Analytics Administrator' #     True
        '4d6ac14f-3453-41d0-bef9-a3e0c569773a' = 'License Administrator' #     True
        '7698a772-787b-4ac8-901f-60d6b08affd2' = 'Cloud Device Administrator' #     True
        'c4e39bd9-1100-46d3-8c65-fb160da0071f' = 'Authentication Administrator' #     True
        '7be44c8a-adaf-4e2a-84d6-ab2649e08a13' = 'Privileged Authentication Administrator' #     True
        'baf37b3a-610e-45da-9e62-d9d1e5e8914b' = 'Teams Communications Administrator' #     True
        'f70938a0-fc10-4177-9e90-2178f8765737' = 'Teams Communications Support Engineer' #     True
        'fcf91098-03e3-41a9-b5ba-6f0ec8188a12' = 'Teams Communications Support Specialist' #     True
        '69091246-20e8-4a56-aa4d-066075b2a7a8' = 'Teams Administrator' #     True
        'eb1f4a8d-243a-41f0-9fbd-c7cdf6c5ef7c' = 'Insights Administrator' #     True
        'ac16e43d-7b2d-40e0-ac05-243ff356ab5b' = 'Message Center Privacy Reader' #     True
        '6e591065-9bad-43ed-90f3-e9424366d2f0' = 'External ID User Flow Administrator' #     True
        '0f971eea-41eb-4569-a71e-57bb8a3eff1e' = 'External ID User Flow Attribute Administrator' #     True
        'aaf43236-0c0d-4d5f-883a-6955382ac081' = 'B2C IEF Keyset Administrator' #     True
        '3edaf663-341e-4475-9f94-5c398ef6c070' = 'B2C IEF Policy Administrator' #     True
        'be2f45a1-457d-42af-a067-6ec1fa63bc45' = 'External Identity Provider Administrator' #     True
        'e6d1a23a-da11-4be4-9570-befc86d067a7' = 'Compliance Data Administrator' #     True
        '5f2222b1-57c3-48ba-8ad5-d4759f1fde6f' = 'Security Operator' #     True
        '74ef975b-6605-40af-a5d2-b9539d836353' = 'Kaizala Administrator' #     True
        'f2ef992c-3afb-46b9-b7cf-a126ee74c451' = 'Global Reader' #     True
        '0964bb5e-9bdb-4d7b-ac29-58e794862a40' = 'Search Administrator' #     True
        '8835291a-918c-4fd7-a9ce-faa49f0cf7d9' = 'Search Editor' #     True
        '966707d0-3269-4727-9be2-8c3a10f19b9d' = 'Password Administrator' #     True
        '644ef478-e28f-4e28-b9dc-3fdde9aa0b1f' = 'Printer Administrator' #     True
        'e8cef6f1-e4bd-4ea8-bc07-4b8d950f4477' = 'Printer Technician' #     True
        '0526716b-113d-4c15-b2c8-68e3c22b9f80' = 'Authentication Policy Administrator' #     True
        'fdd7a751-b60b-444a-984c-02652fe8fa1c' = 'Groups Administrator' #     True
        '11648597-926c-4cf3-9c36-bcebb0ba8dcc' = 'Power Platform Administrator' #     True
        'e3973bdf-4987-49ae-837a-ba8e231c7286' = 'Azure DevOps Administrator' #     True
        '8ac3fc64-6eca-42ea-9e69-59f4c7b60eb2' = 'Hybrid Identity Administrator' #     True
        '2b745bdf-0803-4d80-aa65-822c4493daac' = 'Office Apps Administrator' #     True
        'd37c8bed-0711-4417-ba38-b4abe66ce4c2' = 'Network Administrator' #     True
        '31e939ad-9672-4796-9c2e-873181342d2d' = 'Insights Business Leader' #     True
        '3d762c5a-1b6c-493f-843e-55a3b42923d4' = 'Teams Devices Administrator' #     True
        'c430b396-e693-46cc-96f3-db01bf8bb62a' = 'Attack Simulation Administrator' #     True
        '9c6df0f2-1e7c-4dc3-b195-66dfbd24aa8f' = 'Attack Payload Author' #     True
        '75934031-6c7e-415a-99d7-48dbd49e875e' = 'Usage Summary Reports Reader' #     True
        'b5a8dcf3-09d5-43a9-a639-8e29ef291470' = 'Knowledge Administrator' #     True
        '744ec460-397e-42ad-a462-8b3f9747a02c' = 'Knowledge Manager' #     True
        '8329153b-31d0-4727-b945-745eb3bc5f31' = 'Domain Name Administrator' #     True
        '31392ffb-586c-42d1-9346-e59415a2cc4e' = 'Exchange Recipient Administrator' #     True
        '45d8d3c5-c802-45c6-b32a-1d70b5e1e86e' = 'Identity Governance Administrator' #     True
        '892c5842-a9a6-463a-8041-72aa08ca3cf6' = 'Cloud App Security Administrator' #     True
        '32696413-001a-46ae-978c-ce0f6b3620d2' = 'Windows Update Deployment Administrator' #     True
    }
    if ($All) {
        $Roles.Values
    } else {
        foreach ($Role in $RoleID) {
            $RoleName = $Roles[$Role]
            if ($RoleName) {
                $RoleName
            } else {
                $Role
            }
        }
    }
}
